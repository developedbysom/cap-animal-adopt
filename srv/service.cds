using {sap.capire.animal as my} from '../db/schema';

service AdopterService {

    type adopterInput : {
        name               : String @Core.Immutable;
        email              : String @assert.format: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
        phone              : String @assert.format: '^\d{10}$';
        address            : String @mandatory;
        applicationSummary : String(50);
        update             : Boolean;
    };

    entity Animals               @(restrict: [
        {
            grant: ['READ'],
            to   : 'Adopter'
        },
        {
            grant: ['*'],
            to   : 'Admin'
        }
    ])                          as projection on my.Animals
        actions {

            @Common.DefaultValuesFunction   : 'AdopterService.getDefaults'
            @cds.odata.bindingparameter.name: '_currentRow'
            @Common.SideEffects             : {TargetEntities: [_currentRow]}
            action   Adopt       @(restrict: ['CREATE'])(
                                                         @UI.ParameterDefaultValue:_currentRow.displayName
                                                         name : adopterInput:name,
                                                         phone : adopterInput:phone,
                                                         email : adopterInput:email,
                                                         @UI.MultiLineText:true
                                                         address : adopterInput:address,
                                                         update : adopterInput:update,
                                                         @UI.MultiLineText:true
                                                         applicationSummary : adopterInput:applicationSummary

            );
            function getDefaults @(restrict: ['READ'])() returns adopterInput;
        };

    entity Adopters             as projection on my.Adopters;

    entity AdoptionApplications as
        select from my.AdoptionApplications
        where
            createdBy = $user.id;

    entity MediaFile            as projection on my.MediaFile;
}


// service AdminService {

//     entity AdoptionApplications as projection on my.AdoptionApplications;
//     entity Animals              as projection on my.Animals;
// }

// annotate AdminService.AdoptionApplications with @odata.draft.enabled;
// annotate AdminService with @(requires: 'Admin');
