package nl.knaw.dans.easy.web.template.emd.atomic;

import java.util.ArrayList;
import java.util.List;

import nl.knaw.dans.common.lang.service.exceptions.ServiceException;
import nl.knaw.dans.easy.domain.model.Dataset;
import nl.knaw.dans.easy.servicelayer.services.Services;
import nl.knaw.dans.easy.web.common.DatasetModel;

import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.extensions.ajax.markup.html.IndicatingAjaxLink;
import org.apache.wicket.extensions.ajax.markup.html.modal.ModalWindow;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.markup.html.panel.Panel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ShowFilesPanel extends Panel {
    private static final long serialVersionUID = 1L;

    private static final Logger logger = LoggerFactory.getLogger(ShowFilesPanel.class);

    public ShowFilesPanel(final ModalWindow window, final DatasetModel datasetModel) {
        super(window.getContentId());

        Dataset dataset = datasetModel.getObject();

        List<String> files = new ArrayList<String>();
        try {
            files = Services.getItemService().getFilenames(dataset.getDmoStoreId());
        }
        catch (ServiceException e) {
            logger.error("Something went wrong while trying to get files in ShowFilesPanel.java");
        }

        ListView<String> fileList = new ListView<String>("fileList", files) {
            private static final long serialVersionUID = 1L;

            @Override
            protected void populateItem(ListItem<String> item) {
                item.add(new Label("file", item.getModelObject()));
            }

        };

        add(fileList);

        add(new IndicatingAjaxLink<Void>("close") {
            private static final long serialVersionUID = 1L;

            @Override
            public void onClick(AjaxRequestTarget target) {
                window.close(target);
            }
        });
    }
}