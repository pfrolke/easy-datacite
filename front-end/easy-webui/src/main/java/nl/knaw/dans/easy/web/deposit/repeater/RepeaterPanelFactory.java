package nl.knaw.dans.easy.web.deposit.repeater;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import nl.knaw.dans.common.lang.service.exceptions.ServiceException;
import nl.knaw.dans.easy.domain.deposit.discipline.ChoiceList;
import nl.knaw.dans.easy.domain.deposit.discipline.KeyValuePair;
import nl.knaw.dans.easy.domain.form.ChoiceListDefinition;
import nl.knaw.dans.easy.domain.form.StandardPanelDefinition;
import nl.knaw.dans.easy.domain.form.TermPanelDefinition;
import nl.knaw.dans.easy.web.deposit.repeasy.IdentifierListWrapper;
import nl.knaw.dans.easy.web.wicket.IModelFactory;
import nl.knaw.dans.easy.web.wicket.IPanelFactory;
import nl.knaw.dans.easy.web.wicket.PanelFactoryException;
import nl.knaw.dans.pf.language.emd.EmdDate;

import org.apache.wicket.Component;
import org.apache.wicket.markup.html.panel.Panel;
import org.apache.wicket.model.IModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RepeaterPanelFactory implements IPanelFactory {

    private static final long serialVersionUID = 5974459191267774502L;

    private static final Logger logger = LoggerFactory.getLogger(RepeaterPanelFactory.class);

    private final IModelFactory modelFactory;

    private final Component parentComponent;

    private final String panelWicketId;

    public RepeaterPanelFactory(IModelFactory modelFactory, String panelWicketId, Component parent) {
        this.modelFactory = modelFactory;
        this.panelWicketId = panelWicketId;
        this.parentComponent = parent;
    }

    public String getPanelWicketId() {
        return panelWicketId;
    }

    /**
     * @return the locale
     */
    protected Locale getLocale() {
        return parentComponent == null ? null : parentComponent.getLocale();
    }

    public Panel createPanel(StandardPanelDefinition panelDefinition) throws PanelFactoryException {
        Panel panel = null;
        IModel model = modelFactory.createModel(panelDefinition);
        String methodName = "create" + panelDefinition.getPanelClass();

        try {
            Method method = this.getClass().getMethod(methodName, StandardPanelDefinition.class, IModel.class);
            panel = (Panel) method.invoke(this, panelDefinition, model);
        }
        catch (SecurityException e) {
            final String msg = composeErrorMessage(panelDefinition);
            logger.error(msg, e);
            throw new PanelFactoryException(msg, e);
        }
        catch (NoSuchMethodException e) {
            final String msg = composeErrorMessage(panelDefinition);
            logger.error(msg, e);
            throw new PanelFactoryException(msg, e);
        }
        catch (IllegalArgumentException e) {
            final String msg = composeErrorMessage(panelDefinition);
            logger.error(msg, e);
            throw new PanelFactoryException(msg, e);
        }
        catch (IllegalAccessException e) {
            final String msg = composeErrorMessage(panelDefinition);
            logger.error(msg, e);
            throw new PanelFactoryException(msg, e);
        }
        catch (InvocationTargetException e) {
            final String msg = composeErrorMessage(panelDefinition);
            logger.error(msg, e);
            throw new PanelFactoryException(msg, e);
        }
        return panel;
    }

    private String composeErrorMessage(StandardPanelDefinition spDef) {
        final String msg = "Could not create panel for " + TermPanelDefinition.class.getSimpleName() + ":" + spDef.getId() + "\n\t panelClass="
                + spDef.getPanelClass();
        return msg;
    }

    public Panel createTextFieldPanel(StandardPanelDefinition spDef, IModel model) {
        TextFieldPanel<String> textFieldPanel = new TextFieldPanel<String>(getPanelWicketId(), model);
        textFieldPanel.setPanelDefinition(spDef);
        return textFieldPanel;
    }

    public Panel createAuthorPanel(StandardPanelDefinition spDef, IModel model) {
        AuthorPanel authorPanel = new AuthorPanel(getPanelWicketId(), model);
        authorPanel.setPanelDefinition(spDef);
        return authorPanel;
    }

    public Panel createRadioGroupPanel(StandardPanelDefinition spDef, IModel model) throws ServiceException {
        ChoiceListDefinition choiceDef = spDef.getChoiceListDefinitions().get(0);
        ChoiceList choiceList = modelFactory.getChoiceList(choiceDef.getId(), getLocale());
        RadioChoicePanel radioGroupPanel = new RadioChoicePanel(getPanelWicketId(), model, choiceList);
        radioGroupPanel.setPanelDefinition(spDef);
        return radioGroupPanel;
    }

    public Panel createTextAreaPanel(StandardPanelDefinition spDef, IModel model) {
        TextAreaPanel<String> textAreaPanel = new TextAreaPanel<String>(getPanelWicketId(), model);
        textAreaPanel.setPanelDefinition(spDef);
        return textAreaPanel;
    }

    public Panel createIsoDatePanel(StandardPanelDefinition spDef, IModel model) throws ServiceException {
        ChoiceListDefinition choiceDef = spDef.getChoiceListDefinitions().get(0);
        ChoiceList choiceList = modelFactory.getChoiceList(choiceDef.getId(), getLocale());
        IsoDatePanel datePanel = new IsoDatePanel(getPanelWicketId(), model, choiceList);
        datePanel.setDropdownVisible(true);
        datePanel.setPanelDefinition(spDef);
        return datePanel;
    }

    public Panel createBasicDatePanel(StandardPanelDefinition spDef, IModel model) throws ServiceException {
        ChoiceListDefinition choiceDef = spDef.getChoiceListDefinitions().get(0);
        ChoiceList choiceList = modelFactory.getChoiceList(choiceDef.getId(), getLocale());
        BasicDatePanel basicDatePanel = new BasicDatePanel(getPanelWicketId(), model, choiceList);
        basicDatePanel.setDropdownVisible(true);
        basicDatePanel.setPanelDefinition(spDef);
        return basicDatePanel;
    }

    public Panel createAvailableDatePanel(StandardPanelDefinition spDef, IModel model) throws ServiceException {
        ChoiceListDefinition choiceDef = spDef.getChoiceListDefinitions().get(0);
        ChoiceList choiceList = modelFactory.getChoiceList(choiceDef.getId(), getLocale());
        IsoDatePanel datePanel = new IsoDatePanel(getPanelWicketId(), model, choiceList);
        datePanel.setDefaultKey(EmdDate.AVAILABLE);
        datePanel.setDropdownVisible(false);
        datePanel.setPanelDefinition(spDef);
        return datePanel;
    }

    public Panel createCreatedDatePanel(StandardPanelDefinition spDef, IModel model) throws ServiceException {
        ChoiceListDefinition choiceDef = spDef.getChoiceListDefinitions().get(0);
        ChoiceList choiceList = modelFactory.getChoiceList(choiceDef.getId(), getLocale());
        IsoDatePanel datePanel = new IsoDatePanel(getPanelWicketId(), model, choiceList);
        datePanel.setDefaultKey(EmdDate.CREATED);
        datePanel.setDropdownVisible(false);
        datePanel.setPanelDefinition(spDef);
        return datePanel;
    }

    public Panel createCreatedDatePanel2(StandardPanelDefinition spDef, IModel model) throws ServiceException {
        ChoiceListDefinition choiceDef = spDef.getChoiceListDefinitions().get(0);
        ChoiceList choiceList = modelFactory.getChoiceList(choiceDef.getId(), getLocale());
        BasicDatePanel datePanel = new BasicDatePanel(getPanelWicketId(), model, choiceList);
        datePanel.setDefaultKey(EmdDate.CREATED);
        datePanel.setDropdownVisible(false);
        datePanel.setPanelDefinition(spDef);
        return datePanel;
    }

    public Panel createDropDownChoicePanel(StandardPanelDefinition spDef, IModel model) throws ServiceException {
        ChoiceListDefinition choiceDef = spDef.getChoiceListDefinitions().get(0);
        ChoiceList choiceList = modelFactory.getChoiceList(choiceDef.getId(), getLocale());
        DropDownChoicePanel dropDownChoicePanel = new DropDownChoicePanel(getPanelWicketId(), model, choiceList);
        dropDownChoicePanel.setPanelDefinition(spDef);
        return dropDownChoicePanel;
    }

    public Panel createPointPanel(StandardPanelDefinition spDef, IModel model) throws ServiceException {
        ChoiceListDefinition choiceDef = spDef.getChoiceListDefinitions().get(0);
        ChoiceList choiceList = modelFactory.getChoiceList(choiceDef.getId(), getLocale());
        PointPanel pointPanel = new PointPanel(getPanelWicketId(), model, choiceList);
        pointPanel.setPanelDefinition(spDef);
        return pointPanel;
    }

    public Panel createBoxPanel(StandardPanelDefinition spDef, IModel model) throws ServiceException {
        ChoiceListDefinition choiceDef = spDef.getChoiceListDefinitions().get(0);
        ChoiceList choiceList = modelFactory.getChoiceList(choiceDef.getId(), getLocale());
        BoxPanel boxPanel = new BoxPanel(getPanelWicketId(), model, choiceList);
        boxPanel.setPanelDefinition(spDef);

        return boxPanel;
    }

    public Panel createIdentifierPanel(StandardPanelDefinition spDef, IModel<IdentifierListWrapper> model) throws ServiceException {
        String choiceDefID = spDef.getChoiceListDefinitions().get(0).getId();
        ChoiceList choiceList = modelFactory.getChoiceList(choiceDefID, getLocale());
        return createIdentifierPanel(spDef, model, choiceList);
    }

    public Panel createSimpleIdentifierPanel(StandardPanelDefinition spDef, IModel<IdentifierListWrapper> model) throws ServiceException {
        ChoiceList choiceList = new ChoiceList(new ArrayList<KeyValuePair>());
        return createIdentifierPanel(spDef, model, choiceList);
    }

    private Panel createIdentifierPanel(StandardPanelDefinition spDef, IModel<IdentifierListWrapper> model, ChoiceList choiceList) {
        model.getObject().showNoPeristent(true);
        IdentifierPanel identifierPanel = new IdentifierPanel(getPanelWicketId(), model, choiceList);
        identifierPanel.setPanelDefinition(spDef);
        return identifierPanel;
    }

    public Panel createRelationPanel(StandardPanelDefinition spDef, IModel model) throws ServiceException {
        ChoiceListDefinition choiceDef = spDef.getChoiceListDefinitions().get(0);
        ChoiceList choiceList = modelFactory.getChoiceList(choiceDef.getId(), getLocale());
        RelationPanel relationPanel = new RelationPanel(getPanelWicketId(), model, choiceList);
        relationPanel.setUseRelationType(true);
        relationPanel.setPanelDefinition(spDef);
        return relationPanel;
    }

    public Panel createSimpleRelationPanel(StandardPanelDefinition spDef, IModel model) throws ServiceException {
        ChoiceListDefinition choiceDef = spDef.getChoiceListDefinitions().get(0);
        ChoiceList choiceList = modelFactory.getChoiceList(choiceDef.getId(), getLocale());
        RelationPanel relationPanel = new RelationPanel(getPanelWicketId(), model, choiceList);
        relationPanel.setUseRelationType(false);
        relationPanel.setPanelDefinition(spDef);
        return relationPanel;
    }
}