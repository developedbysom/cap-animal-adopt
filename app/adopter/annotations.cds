using AdopterService as service from '../../srv/service';
using from '../../db/Schema';

annotate service.adopterInput with {
    name               @Common.Label: 'You are adopting';
    address            @Common.Label: 'Address';
    phone              @Common.Label: 'Phone';
    update             @Common.Label: 'Update';
    email              @Common.Label: 'Email';
    applicationSummary @Common.Label: 'Summary';

};

annotate service.Animals with @(

    UI.SelectionPresentationVariant #SelPreVarAVL: {
        $Type              : 'UI.SelectionPresentationVariantType',
        Text               : 'All Animals',
        SelectionVariant   : {
            $Type        : 'UI.SelectionVariantType',
            Text         : 'All Animals',
            SelectOptions: [{
                $Type       : 'UI.SelectOptionType',
                PropertyName: adoptionStatus_code,
                Ranges      : [{
                    $Type : 'UI.SelectionRangeType',
                    Sign  : #I,
                    Option: #EQ,
                    Low   : 'A'
                }]
            }]
        },
        PresentationVariant: {
            $Type         : 'UI.PresentationVariantType',
            Visualizations: ['@UI.LineItem#AnimalsAvl'],
            SortOrder     : [{
                $Type     : 'Common.SortOrderType',
                Property  : ID,
                Descending: false
            }]
        }
    },

    UI.SelectionPresentationVariant #SelPreVarPEN: {
        $Type              : 'UI.SelectionPresentationVariantType',
        Text               : '{i18n>Pending}',
        SelectionVariant   : {
            $Type        : 'UI.SelectionVariantType',
            Text         : 'Pending',
            SelectOptions: [{
                $Type       : 'UI.SelectOptionType',
                PropertyName: adoptionStatus_code,
                Ranges      : [{
                    $Type : 'UI.SelectionRangeType',
                    Sign  : #I,
                    Option: #EQ,
                    Low   : 'P'
                }]
            }]
        },
        PresentationVariant: {
            $Type         : 'UI.PresentationVariantType',
            Visualizations: ['@UI.LineItem#Pending'],
            SortOrder     : [{
                $Type     : 'Common.SortOrderType',
                Property  : ID,
                Descending: false
            }],
            GroupBy       : [displayName]
        }
    },

    UI.SelectionFields                           : [
        adoptionStatus_code,
        healthStatus_code,
        species_code,
    ],
    UI.LineItem #AnimalsAvl                      : [
        {
            $Type: 'UI.DataField',
            Value: displayName,
            Label: '{i18n>Name}',
        },
        {
            $Type                    : 'UI.DataField',
            Value                    : healthStatus_code,
            Criticality              : healthStatus.criticality,
            CriticalityRepresentation: #WithIcon,
        },
        {
            $Type: 'UI.DataField',
            Value: breed,
            Label: '{i18n>Breed}',
        },
        {
            $Type: 'UI.DataField',
            Value: age,
            Label: '{i18n>Age}',
        },
        {
            $Type: 'UI.DataField',
            Value: adoptionStatus_code,
        },
        {
            $Type      : 'UI.DataFieldForAction',
            Action     : 'AdopterService.Adopt',
            Label      : 'Adopt',
            Inline     : true,
            Criticality: #Positive,
            @UI.Hidden : {$edmJson: {$Ne: [
                {$Path: 'adoptionStatus_code'},
                'A'
            ]}}
        },
    ],

    UI.LineItem #Pending                         : [
        {
            $Type: 'UI.DataField',
            Value: displayName,
            Label: '{i18n>Name}',
        },
        {
            $Type                    : 'UI.DataField',
            Value                    : healthStatus_code,
            Criticality              : healthStatus.criticality,
            CriticalityRepresentation: #WithIcon,
        },
        {
            $Type: 'UI.DataField',
            Value: breed,
            Label: '{i18n>Breed}',
        },
        {
            $Type: 'UI.DataField',
            Value: age,
            Label: '{i18n>Age}',
        },
        {
            $Type: 'UI.DataField',
            Value: adoptionStatus_code,
        },
        {
            $Type      : 'UI.DataFieldForAction',
            Action     : 'AdopterService.Adopt',
            Label      : 'Adopt',
            Inline     : true,
            Criticality: #Positive,
            @UI.Hidden : {$edmJson: {$Ne: [
                {$Path: 'adoptionStatus_code'},
                'A'
            ]}}
        },
    ],

    UI.HeaderInfo                                : {
        Title         : {
            $Type: 'UI.DataField',
            Value: displayName,
        },
        TypeName      : '',
        TypeNamePlural: '',
        Description   : {
            $Type: 'UI.DataField',
            Value: breed,
        },
    },
    UI.Facets                                    : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : '{i18n>Details}',
            ID    : 'i18nDetails',
            Target: '@UI.FieldGroup#i18nDetails',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : '{i18n>AdopterDetails}',
            ID    : 'i18nAdopterDetails',
            Target: '@UI.FieldGroup#i18nAdopterDetails',
        },
    ],
    UI.FieldGroup #i18nDetails                   : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type                    : 'UI.DataField',
                Value                    : healthStatus_code,
                Criticality              : healthStatus.criticality,
                CriticalityRepresentation: #WithIcon,
            },
            {
                $Type: 'UI.DataField',
                Value: age,
                Label: 'age',
            },
            {
                $Type: 'UI.DataField',
                Value: adoptionStatus_code,
            },
            {
                $Type: 'UI.DataField',
                Value: species_code,
            },
        ],
    },
    UI.FieldGroup #i18nAdopterDetails            : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: adopter.name,
                Label: '{i18n>Name}',
            },
            {
                $Type: 'UI.DataField',
                Value: adopter.address,
                Label: '{i18n>Address}',
            },
            {
                $Type: 'UI.DataField',
                Value: adopter.email,
                Label: 'email',
            },
            {
                $Type: 'UI.DataField',
                Value: adopter.phone,
                Label: 'phone',
            },
        ],
    },
);

annotate service.Animals with {
    adoptionStatus @(
        Common.Label                   : '{i18n>AdoptionStatus}',
        Common.ValueListWithFixedValues: true,
        Common.Text                    : {
            $value                : adoptionStatus.name,
            ![@UI.TextArrangement]: #TextOnly
        },
    )
};

annotate service.Animals with {
    healthStatus @(
        Common.Label                   : '{i18n>HealthStatus}',
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'HealthStatus',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: healthStatus_code,
                ValueListProperty: 'name',
            }, ],
        },
        Common.ValueListWithFixedValues: false,
        Common.Text                    : {
            $value                : healthStatus.name,
            ![@UI.TextArrangement]: #TextOnly
        },
    )
};

annotate service.Animals with {
    species @Common.Label: '{i18n>Species}'
};

annotate service.AdoptionStatuses with {
    code @Common.Text: {
        $value                : name,
        ![@UI.TextArrangement]: #TextLast,
    }
};
