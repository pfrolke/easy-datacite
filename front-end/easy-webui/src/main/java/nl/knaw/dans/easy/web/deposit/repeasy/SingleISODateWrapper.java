package nl.knaw.dans.easy.web.deposit.repeasy;

import java.util.ArrayList;
import java.util.List;

import nl.knaw.dans.easy.domain.deposit.discipline.KeyValuePair;
import nl.knaw.dans.easy.web.deposit.repeater.AbstractEasyModel;
import nl.knaw.dans.easy.web.deposit.repeater.AbstractListWrapper;
import nl.knaw.dans.easy.web.wicket.KvpChoiceRenderer;
import nl.knaw.dans.pf.language.emd.types.IsoDate;

import org.apache.wicket.markup.html.form.ChoiceRenderer;

public class SingleISODateWrapper extends AbstractListWrapper<SingleISODateWrapper.DateModel>
{

    private static final long serialVersionUID = -7329761811695091371L;

    List<IsoDate> isoDateList = new ArrayList<IsoDate>();

    public SingleISODateWrapper(List<IsoDate> isoDateList)
    {
        this.isoDateList = isoDateList;
    }

    public ChoiceRenderer getChoiceRenderer()
    {
        return new KvpChoiceRenderer();
    }

    public DateModel getEmptyValue()
    {
        return new DateModel();
    }

    public List<DateModel> getInitialItems()
    {
        List<DateModel> listItems = new ArrayList<DateModel>();

        for (IsoDate isoDate : isoDateList)
        {
            listItems.add(new DateModel(isoDate));
        }

        return listItems;
    }

    @Override
    public int size()
    {
        return isoDateList.size();
    }

    public int synchronize(List<DateModel> listItems)
    {

        // clear previous entries
        isoDateList.clear();
        // add new entries
        int errors = 0;
        for (int i = 0; i < listItems.size(); i++)
        {
            DateModel model = listItems.get(i);
            IsoDate isoDate = null;
            isoDate = model.getIsoDate();
            if (isoDate != null)
            {
                isoDateList.add(isoDate);
            }
            if (model.hasErrors())
            {
                handleErrors(model.getErrors(), i);
                errors += model.getErrors().size();
            }
            model.clearErrors();
        }
        return errors;
    }

    public static class DateModel extends AbstractEasyModel implements QualifiedModel
    {
        private static final long serialVersionUID = 3841830259279016843L;
        public static final String DATE_FORMAT = "YYYY-MM-dd";

        private String dateSchemeType;
        private String value;

        public DateModel(IsoDate isoDate)
        {
            if (isoDate == null)
            {
                throw new IllegalArgumentException("Model for IsoDate cannot be created.");
            }
            this.value = isoDate.toString();
        }

        protected DateModel()
        {
        }

        public String getValue()
        {
            return value;
        }

        public void setValue(String value)
        {
            // wicket 1.4 DatePicker bug workaround
            if (value != null && value.length() == 8)
            {
                if (value.charAt(2) == '-' && value.charAt(5) == '-')
                {
                    value = "20" + value;
                }
            }
            this.value = value;
        }

        public IsoDate getIsoDate()
        {
            return value == null ? null : convertToDateTime(value);
        }

        public void setScheme(KeyValuePair schemeKVP)
        {
            dateSchemeType = schemeKVP == null ? null : schemeKVP.getKey();
        }

        public KeyValuePair getScheme()
        {
            return new KeyValuePair(dateSchemeType, null);
        }

        // Quick fix (Do not try this at home!)
        @Override
        public String getQualifier()
        {
            return dateSchemeType;
        }
    }
}