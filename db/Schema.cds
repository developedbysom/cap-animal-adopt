using {
    sap.common.CodeList,
    cuid,
    managed
} from '@sap/cds/common';

namespace sap.capire.animal;

entity Animals : cuid {
    name           : String;
    species        : Association to Species;
    breed          : String;
    age            : Integer;
    healthStatus   : Association to HealthStatus;
    adoptionStatus : Association to AdoptionStatuses;
    adopter        : Association to Adopters;
    displayName    : String = name || ' - (' || species.name || ')';
    mediaFile      : Composition of many MediaFile
                         on mediaFile.animal = $self;

}

entity MediaFile : cuid, managed {
    animal    : Association to Animals;

    @Core.ContentDisposition.Filename: fileName
    @Core.MediaType                  : mediaType
    @Core.ContentDisposition.Type    : 'inline'
    content   : LargeBinary;
    fileName  : String;

    @Core.IsMediaType                : true
    mediaType : String default 'application/octet-stream';
    url       : String;
}

entity Adopters : cuid, managed {
    name           : String;
    email          : String @assert.format: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    phone          : String @assert.format: '^\d{10}$';
    address        : String;
    virtual update : Boolean;
}

entity AdoptionApplications : cuid, managed {
    animal             : Association to Animals;
    adopter            : Association to Adopters;
    applicationDate    : type of managed : createdAt;
    applicationSummary : String(100);
}

entity Species : CodeList {
    key code : String enum {
            Cat    = 'CA';
            Rabbit = 'RB';
            Bird   = 'BD';
            Dog    = 'DG';
        }
}

entity HealthStatus : CodeList {
    key code        : String enum {
            Healthy          = 'H';
            RequireAttention = 'RA';
            Critical         = 'C';
        };
        criticality : Integer;
}

entity AdoptionStatuses : CodeList {
    key code : String enum {
            Available = 'A';
            Pending   = 'P';
            Adopted   = 'AD';
        };
}
