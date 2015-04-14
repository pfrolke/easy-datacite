package nl.knaw.dans.easy.business.services;

import java.io.File;
import java.io.FileFilter;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Comparator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import nl.knaw.dans.common.jibx.JiBXObjectFactory;
import nl.knaw.dans.common.lang.RepositoryException;
import nl.knaw.dans.common.lang.repo.DmoStoreId;
import nl.knaw.dans.common.lang.repo.UnitOfWork;
import nl.knaw.dans.common.lang.repo.exception.ObjectNotInStoreException;
import nl.knaw.dans.common.lang.repo.exception.UnitOfWorkInterruptException;
import nl.knaw.dans.common.lang.security.authz.AuthzStrategy;
import nl.knaw.dans.common.lang.service.exceptions.CommonSecurityException;
import nl.knaw.dans.common.lang.service.exceptions.ObjectNotAvailableException;
import nl.knaw.dans.common.lang.service.exceptions.ServiceException;
import nl.knaw.dans.common.lang.xml.SchemaCreationException;
import nl.knaw.dans.common.lang.xml.ValidatorException;
import nl.knaw.dans.common.lang.xml.XMLDeserializationException;
import nl.knaw.dans.common.lang.xml.XMLErrorHandler;
import nl.knaw.dans.easy.business.item.DownloadRegistration;
import nl.knaw.dans.easy.business.item.DownloadWorkDispatcher;
import nl.knaw.dans.easy.business.item.ItemIngester;
import nl.knaw.dans.easy.business.item.ItemIngesterDelegator;
import nl.knaw.dans.easy.business.item.ItemWorkDispatcher;
import nl.knaw.dans.easy.business.md.amd.AdditionalMetadataUpdateStrategy;
import nl.knaw.dans.easy.data.Data;
import nl.knaw.dans.easy.data.store.EasyUnitOfWork;
import nl.knaw.dans.easy.data.store.StoreAccessException;
import nl.knaw.dans.easy.domain.annotations.MutatesDataset;
import nl.knaw.dans.easy.domain.dataset.EasyFile;
import nl.knaw.dans.easy.domain.dataset.FileItemDescription;
import nl.knaw.dans.easy.domain.dataset.item.AbstractItemVO;
import nl.knaw.dans.easy.domain.dataset.item.FileItemVO;
import nl.knaw.dans.easy.domain.dataset.item.FolderItemVO;
import nl.knaw.dans.easy.domain.dataset.item.ItemOrder;
import nl.knaw.dans.easy.domain.dataset.item.ItemVO;
import nl.knaw.dans.easy.domain.dataset.item.RequestedItem;
import nl.knaw.dans.easy.domain.dataset.item.UpdateInfo;
import nl.knaw.dans.easy.domain.dataset.item.filter.ItemFilters;
import nl.knaw.dans.easy.domain.download.FileContentWrapper;
import nl.knaw.dans.easy.domain.download.ZipFileContentWrapper;
import nl.knaw.dans.easy.domain.exceptions.ApplicationException;
import nl.knaw.dans.easy.domain.model.AccessibleTo;
import nl.knaw.dans.easy.domain.model.Dataset;
import nl.knaw.dans.easy.domain.model.DatasetItemContainer;
import nl.knaw.dans.easy.domain.model.FileItem;
import nl.knaw.dans.easy.domain.model.FolderItem;
import nl.knaw.dans.easy.domain.model.VisibleTo;
import nl.knaw.dans.easy.domain.model.user.CreatorRole;
import nl.knaw.dans.easy.domain.model.user.EasyUser;
import nl.knaw.dans.easy.domain.worker.WorkListener;
import nl.knaw.dans.easy.security.authz.AuthzStrategyProvider;
import nl.knaw.dans.easy.servicelayer.services.ItemService;
import nl.knaw.dans.easy.servicelayer.services.Services;
import nl.knaw.dans.easy.xml.ResourceMetadataList;
import nl.knaw.dans.easy.xml.ResourceMetadataListValidator;
import nl.knaw.dans.pf.language.emd.types.BasicIdentifier;
import nl.knaw.dans.pf.language.emd.types.EmdConstants;
import nl.knaw.dans.pf.language.emd.types.Relation;

import org.dom4j.Element;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;

public class EasyItemService extends AbstractEasyService implements ItemService {

    private static final Logger logger = LoggerFactory.getLogger(EasyItemService.class);

    private ItemWorkDispatcher itemWorDispatcher;
    private DownloadWorkDispatcher downloadWorkDispatcher;

    private boolean processDataFileInstructions;

    @Override
    public FileItem getFileItem(EasyUser sessionUser, Dataset dataset, DmoStoreId fileItemId) throws ObjectNotAvailableException, CommonSecurityException,
            ServiceException
    {
        FileItem fileItem = getItemWorkDispatcher().getFileItem(sessionUser, dataset, fileItemId);
        return fileItem;
    }

    @Override
    public FileItem getFileItemByPath(EasyUser sessionUser, Dataset dataset, String path) throws ObjectNotAvailableException, CommonSecurityException,
            ServiceException
    {
        FileItem fileItem = getItemWorkDispatcher().getFileItemByPath(sessionUser, dataset, path);
        return fileItem;
    }

    @Override
    public FolderItem getFolderItemByPath(EasyUser sessionUser, Dataset dataset, String path) throws ObjectNotAvailableException, CommonSecurityException,
            ServiceException
    {
        FolderItem folderItem = getItemWorkDispatcher().getFolderItemByPath(sessionUser, dataset, path);
        return folderItem;
    }

    @Override
    public FileItemDescription getFileItemDescription(EasyUser sessionUser, Dataset dataset, DmoStoreId fileItemId) throws ObjectNotAvailableException,
            CommonSecurityException, ServiceException
    {
        FileItem fileItem = getFileItem(dataset, fileItemId);
        return getItemWorkDispatcher().getFileItemDescription(sessionUser, dataset, fileItem);
    }

    @Override
    public URL getFileContentURL(EasyUser sessionUser, Dataset dataset, FileItem fileItem) throws ObjectNotAvailableException, CommonSecurityException,
            ServiceException
    {
        return getItemWorkDispatcher().getFileContentURL(sessionUser, dataset, fileItem);
    }

    @Override
    public URL getDescriptiveMetadataURL(EasyUser sessionUser, Dataset dataset, DmoStoreId fileItemId) throws ObjectNotAvailableException,
            CommonSecurityException, ServiceException, RepositoryException
    {
        return getItemWorkDispatcher().getDescriptiveMetadataURL(sessionUser, dataset, fileItemId);
    }

    // used by web-ui
    @Override
    public void addDirectoryContents(EasyUser sessionUser, Dataset dataset, DmoStoreId parentId, File rootFile, List<File> filesToIngest,
            WorkListener... workListeners) throws ServiceException
    {
        FileFilter ingestFilter = new ItemIngester.ListFilter(filesToIngest);
        addDirectoryContents(sessionUser, dataset, parentId, rootFile, ingestFilter, null, workListeners);
    }

    // used by repo tools, batch ingest
    @Override
    public void addDirectoryContents(EasyUser sessionUser, Dataset dataset, DmoStoreId parentId, File rootFile, ItemIngesterDelegator delegator,
            WorkListener... workListeners) throws ServiceException
    {
        FileFilter ingestFilter = new ItemIngester.IngestFilter();
        addDirectoryContents(sessionUser, dataset, parentId, rootFile, ingestFilter, delegator, workListeners);
    }

    @MutatesDataset
    private void addDirectoryContents(EasyUser sessionUser, Dataset dataset, DmoStoreId parentId, File rootFile, FileFilter ingestFilter,
            ItemIngesterDelegator delegator, WorkListener... workListeners) throws ServiceException
    {
        UnitOfWork uow = new EasyUnitOfWork(sessionUser);

        try {
            uow.attach(dataset); // most important: dataset and parentContainer may be the same object
            DatasetItemContainer parentContainer;
            if (parentId == null) {
                parentContainer = dataset;
            } else {
                parentContainer = (DatasetItemContainer) uow.retrieveObject(parentId);
            }
            getItemWorkDispatcher().addDirectoryContents(sessionUser, dataset, parentContainer, rootFile, ingestFilter, uow, delegator, workListeners);
        }
        catch (final ObjectNotInStoreException e) {
            throw new ObjectNotAvailableException(e);
        }
        catch (final ApplicationException e) {
            throw new ServiceException(e);
        }
        catch (final RepositoryException e) {
            throw new ServiceException(e);
        }
        finally {
            uow.close();
        }
    }

    /**
     * {@inheritDoc}
     */
    @MutatesDataset
    public void updateObjects(EasyUser sessionUser, Dataset dataset, List<DmoStoreId> sidList, UpdateInfo updateInfo) throws ServiceException {
        if (sidList.isEmpty()) {
            return;
        }

        UnitOfWork uow = new EasyUnitOfWork(sessionUser,
        /*
         * Makes sure that items are processed in the order files, folders, dataset.
         */
        new Comparator<DmoStoreId>() {
            @Override
            public int compare(DmoStoreId sid1, DmoStoreId sid2) {
                if (sid1.isInNamespace(Dataset.NAMESPACE))
                    return 1;
                else if (sid1.isInNamespace(FolderItem.NAMESPACE)) {
                    if (sid2.isInNamespace(Dataset.NAMESPACE))
                        return -1;
                    else
                        return 1;
                } else
                    return -1;
            }
        });

        try {
            uow.attach(dataset);
            getItemWorkDispatcher().updateObjects(sessionUser, dataset, sidList, updateInfo, uow);
        }
        catch (RepositoryException e) {
            logger.error("Something went wrong trying to update objects.", e);
        }
        finally {
            uow.close();
        }
    }

    @Override
    public void updateFileItemMetadata(EasyUser sessionUser, Dataset dataset, File file, AdditionalMetadataUpdateStrategy strategy,
            WorkListener... workListeners) throws ServiceException
    {
        try {
            XMLErrorHandler handler = ResourceMetadataListValidator.instance().validate(file, null);
            if (!handler.passed()) {
                logger.warn("Invalid resource metadata: " + handler.getMessages());
                throw new ServiceException("Invalid resource metadata: " + handler.getMessages());
            }
        }
        catch (ValidatorException e) {
            throw new ServiceException(e);
        }
        catch (SAXException e) {
            throw new ServiceException(e);
        }
        catch (SchemaCreationException e) {
            throw new ServiceException(e);
        }

        try {
            ResourceMetadataList rmdList = (ResourceMetadataList) JiBXObjectFactory.unmarshal(ResourceMetadataList.class, file);
            updateFileItemMetadata(sessionUser, dataset, rmdList, strategy, workListeners);
        }
        catch (XMLDeserializationException e) {
            throw new ServiceException(e);
        }

    }

    @Override
    public void updateFileItemMetadata(EasyUser sessionUser, Dataset dataset, ResourceMetadataList resourceMetadataList,
            AdditionalMetadataUpdateStrategy strategy, WorkListener... workListeners) throws ServiceException
    {
        getItemWorkDispatcher().updateFileItemMetadata(sessionUser, dataset, resourceMetadataList, strategy, workListeners);

    }

    // old fashioned additional metadata
    @MutatesDataset
    @Deprecated
    public void saveDescriptiveMetadata(EasyUser sessionUser, final Dataset dataset, final Map<String, Element> descriptiveMetadataMap) throws ServiceException
    {
        final UnitOfWork uow = new EasyUnitOfWork(sessionUser);
        try {
            getItemWorkDispatcher().saveDescriptiveMetadata(sessionUser, uow, dataset, descriptiveMetadataMap);
            uow.commit();
        }
        catch (final RepositoryException e) {
            throw new ServiceException(e);
        }
        catch (final UnitOfWorkInterruptException e) {
            throw new ServiceException(e);
        }
        finally {
            uow.close();
        }
    }

    public List<String> getFilenames(final DmoStoreId parentSid) throws ServiceException {
        try {
            return Data.getFileStoreAccess().getFilenames(parentSid);
        }
        catch (final StoreAccessException e) {
            throw new ServiceException(e);
        }
    }

    public List<ItemVO> getFilesAndFolders(EasyUser sessionUser, Dataset dataset, final DmoStoreId parentSid) throws ServiceException {
        List<ItemVO> itemList;
        try {

            itemList = Data.getFileStoreAccess().getFilesAndFolders(parentSid);
        }
        catch (final StoreAccessException e) {
            throw new ServiceException(e);
        }

        setAuthzStrategy(sessionUser, dataset, itemList);
        return itemList;
    }

    public boolean hasChildItems(final DmoStoreId parentSid) throws ServiceException {
        try {
            return Data.getFileStoreAccess().hasChildItems(parentSid);
        }
        catch (final StoreAccessException e) {
            throw new ServiceException(e);
        }
    }

    public List<FileItemVO> getFiles(EasyUser sessionUser, Dataset dataset, final DmoStoreId parentSid) throws ServiceException {
        List<FileItemVO> fileItemList;
        try {
            fileItemList = Data.getFileStoreAccess().getFiles(parentSid);
        }
        catch (final StoreAccessException e) {
            throw new ServiceException(e);
        }
        setAuthzStrategy(sessionUser, dataset, fileItemList);
        return fileItemList;
    }

    public List<FolderItemVO> getFolders(EasyUser sessionUser, Dataset dataset, final DmoStoreId parentSid, final Integer limit, final Integer offset,
            final ItemOrder order, final ItemFilters filters) throws ServiceException
    {
        List<FolderItemVO> folderItemList;
        try {
            folderItemList = Data.getFileStoreAccess().getFolders(parentSid);
        }
        catch (final StoreAccessException e) {
            throw new ServiceException(e);
        }

        setAuthzStrategy(sessionUser, dataset, folderItemList);
        return folderItemList;
    }

    @Override
    public Collection<FileItemVO> getFileItemsRecursively(EasyUser sessionUser, Dataset dataset, Collection<FileItemVO> items, ItemFilters filter,
            DmoStoreId... storeIds) throws ServiceException
    {
        AuthzStrategyProvider provider = new AuthzStrategyProvider(sessionUser, dataset);
        return getFileItemsRecursively(provider, items, filter, storeIds);
    }

    private Collection<FileItemVO> getFileItemsRecursively(AuthzStrategyProvider provider, final Collection<FileItemVO> items, final ItemFilters filter,
            final DmoStoreId... storeIds) throws ServiceException
    {
        try {
            for (final DmoStoreId storeId : storeIds) {
                if (storeId.isInNamespace(FileItem.NAMESPACE)) {
                    items.add(Data.getFileStoreAccess().findFileById(storeId));
                } else {
                    for (final ItemVO item : Data.getFileStoreAccess().getFilesAndFolders(storeId)) {
                        if (item instanceof FileItemVO) {
                            items.add((FileItemVO) item);
                            AuthzStrategy strategy = provider.getAuthzStrategy(item.getAutzStrategyName(), item);
                            ((AbstractItemVO) item).setAuthzStrategy(strategy);
                        } else {
                            getFileItemsRecursively(provider, items, filter, new DmoStoreId(((FolderItemVO) item).getSid()));
                        }
                    }
                }
            }
        }
        catch (StoreAccessException e) {
            throw new ServiceException(e);
        }
        return items;
    }

    /**
     * {@inheritDoc}
     */
    public FileContentWrapper getContent(EasyUser sessionUser, final Dataset dataset, final DmoStoreId fileItemId) throws ServiceException {
        final FileContentWrapper fileContentWrapper = getDownloadWorkDispatcher().prepareFileContent(sessionUser, dataset, fileItemId);
        if (logger.isDebugEnabled()) {
            logger.debug("Returning file content link for " + fileContentWrapper.toString());
        }

        return fileContentWrapper;
    }

    /**
     * {@inheritDoc}
     */
    public ZipFileContentWrapper getZippedContent(EasyUser sessionUser, final Dataset dataset, final Collection<RequestedItem> requestedItems)
            throws ServiceException
    {
        final ZipFileContentWrapper zipFileContentWrapper = getDownloadWorkDispatcher().prepareZippedContent(sessionUser, dataset, requestedItems);
        if (logger.isDebugEnabled()) {
            logger.debug("Returning zipped files from " + getStoreId(dataset) + " to " + getUserId(sessionUser));
        }
        return zipFileContentWrapper;
    }

    private ItemWorkDispatcher getItemWorkDispatcher() {
        if (itemWorDispatcher == null) {
            itemWorDispatcher = new ItemWorkDispatcher();
        }
        return itemWorDispatcher;
    }

    private DownloadWorkDispatcher getDownloadWorkDispatcher() {
        if (downloadWorkDispatcher == null) {
            downloadWorkDispatcher = new DownloadWorkDispatcher();
        }
        return downloadWorkDispatcher;
    }

    private void setAuthzStrategy(EasyUser sessionUser, Dataset dataset, List<? extends ItemVO> itemList) {
        AuthzStrategyProvider provider = new AuthzStrategyProvider(sessionUser, dataset);
        for (ItemVO itemVO : itemList) {
            AuthzStrategy strategy = provider.getAuthzStrategy(itemVO.getAutzStrategyName(), itemVO);
            ((AbstractItemVO) itemVO).setAuthzStrategy(strategy);
        }
    }

    private void setAuthzStrategy(EasyUser sessionUser, Dataset dataset, ItemVO... itemList) {
        setAuthzStrategy(sessionUser, dataset, Arrays.asList(itemList));
    }

    private FileItem getFileItem(Dataset dataset, DmoStoreId fileItemId) throws ObjectNotAvailableException, ServiceException {
        FileItem fileItem;
        try {
            fileItem = (FileItem) Data.getEasyStore().retrieve(fileItemId);
            if (!fileItem.getFileItemMetadata().getDatasetDmoStoreId().equals(dataset.getDmoStoreId())) {
                throw new ObjectNotAvailableException("FileItem '" + fileItemId + "' does not belong to dataset '" + dataset.getStoreId() + "'");
            }
        }
        catch (ObjectNotInStoreException e) {
            throw new ObjectNotAvailableException(e);
        }
        catch (RepositoryException e) {
            throw new ServiceException(e);
        }
        return fileItem;
    }

    @Override
    public void registerDownload(EasyUser sessionUser, Dataset dataset, List<? extends ItemVO> downloads) {
        DownloadRegistration registration = new DownloadRegistration(sessionUser, dataset, downloads);
        registration.registerDownloads();
    }

    @Override
    public boolean allAccessibleToUser(EasyUser sessionUser, Collection<FileItemVO> files) throws ServiceException {
        for (FileItemVO fileItem : files) {
            if (!fileItem.getAuthzStrategy().canUnitBeRead(EasyFile.UNIT_ID))
                return false;
        }
        return true;
    }

    @Override
    public Collection<FileItemVO> getAudioVideoFiles(EasyUser sessionUser, Dataset dataset) throws ServiceException {
        Collection<FileItemVO> fileItems = getFileItemsRecursively(sessionUser, dataset, new ArrayList<FileItemVO>(), null, dataset.getDmoStoreId());
        Collection<FileItemVO> result = new LinkedList<FileItemVO>();
        for (FileItemVO fileItem : fileItems) {
            DmoStoreId fileItemId = new DmoStoreId(fileItem.getSid());
            FileItemDescription description = Services.getItemService().getFileItemDescription(sessionUser, dataset, fileItemId);
            String mime = description.getFileItemMetadata().getMimeType();
            if (mime != null && (mime.startsWith("video/") || mime.startsWith("audio/"))) {
                result.add(fileItem);
            }
        }
        return result;
    }

    @Override
    public void setProcessDataFileInstructions(boolean value) {
        processDataFileInstructions = value;
    }

    @Override
    public boolean mustProcessDataFileInstructions() {
        return processDataFileInstructions;
    }

    @Override
    public FolderItemVO getRootFolder(EasyUser sessionUser, Dataset dataset, DmoStoreId dmoStoreId) throws ServiceException {
        FolderItemVO root;
        try {
            root = Data.getFileStoreAccess().getRootFolder(dmoStoreId);
        }
        catch (final StoreAccessException e) {
            throw new ServiceException(e);
        }

        setAuthzStrategy(sessionUser, dataset, root);
        return root;
    }

    @Override
    public Set<AccessibleTo> getItemVoAccessibilities(ItemVO item) throws StoreAccessException {
        return Data.getFileStoreAccess().getItemVoAccessibilities(item);
    }

    @Override
    public Set<VisibleTo> getItemVoVisibilities(ItemVO item) throws StoreAccessException {
        return Data.getFileStoreAccess().getItemVoVisibilities(item);
    }

    @Override
    public Set<CreatorRole> getItemVoCreatorRoles(ItemVO item) throws StoreAccessException {
        return Data.getFileStoreAccess().getItemVoCreatorRoles(item);
    }

    @Override
    public String getPresentationFromRelations(Dataset dataset) {
        List<BasicIdentifier> relations = dataset.getEasyMetadata().getEmdRelation().getDcRelation();
        for (BasicIdentifier r : relations) {
            if (EmdConstants.SCHEME_STREAMING_SURROGATE_RELATION.equals(r.getScheme())) {
                return r.getValue();
            }
        }
        return null;
    }

}