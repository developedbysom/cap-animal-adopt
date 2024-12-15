const cds = require("@sap/cds");

module.exports = class AdopterService extends cds.ApplicationService {
  async getDefaults(entity, id) {
    //Here id will return Animal id -> to be queries with expansion
    //to get Adopter ID and followed by Adopter details
    const { Adopters } = cds.entities;
    const { user } = cds.context;

    const result = await SELECT.one(Adopters)
      .columns("phone", "address", "email")
      .where({ createdBy: user.id });

    if (result) {
      const { email, address, phone } = result;
      return {
        name: "",
        email: email,
        phone: phone,
        address: address,
        applicationSummary: "",
        update: "",
      };
    } else {
      return {
        name: "",
        email: " ",
        phone: "",
        address: "",
        applicationSummary: "",
        update: "",
      };
    }
  }

  init() {
    this.on("READ", "Animals", async (req) => {
      const { Animals } = cds.entities;
      const { func } = req.query.SELECT.columns[0];

      let result;

      if (func == "count") {
        return cds.run(req.query);
      } else {
        result = await SELECT.from(Animals)
          .columns((a) => {
            a`.*`,
              a.healthStatus((hs) => {
                hs.name;
                hs.criticality;
              }),
              a.adoptionStatus((as) => {
                as.name;
              });
            a.adopter`[createdBy = ${req.user.id}]`((ad) => {
              ad.email, ad.phone, ad.address, ad.name;
            });
          })
          .where(req.query.SELECT.where);

        result.$count = result.length;
      }

      return result;
    });
    this.on("DELETE", "AdoptionApplications", async (req) => {
      const { Animals, AdoptionApplications } = cds.entities;

      //GEt the adoption application ID
      const { ID } = req.data;

      // Select the animal ID against the application
      const { animal_ID } = await SELECT.one(
        AdoptionApplications,
        (A) => A.animal_ID
      ).where({
        ID: ID,
      });
      // Delete the selected application

      await DELETE.from(AdoptionApplications).where({
        ID: ID,
      });
      // Update the animal adotion status also remove the adopter linkage
      await UPDATE.entity(Animals)
        .with({
          adoptionStatus_code: "A",
          adopter_ID: null,
        })
        .where({
          ID: animal_ID,
        });
    });
    this.on("Adopt", "Animals", async (req) => {
      //get the Adopter ID
      const { Animals, AdoptionApplications } = cds.entities;
      const { applicationSummary } = req.data;
      const adopterID = await this.getAdopterID(req);
      const animalID = req.params[0];

      //Create entry for AdoptionApplication
      await INSERT.into(AdoptionApplications).entries({
        animal_ID: animalID,
        adopter_ID: adopterID,
        applicationSummary: applicationSummary,
      });

      await UPDATE.entity(Animals)
        .with({
          adoptionStatus_code: "P",
          adopter_ID: adopterID,
        })
        .where({
          ID: animalID,
        });
    });

    return super.init();
  }

  async getAdopterID(req) {
    const { Adopters } = cds.entities;
    const { name, address, phone, email, update } = req.data;

    const result = await SELECT.one(Adopters, (A) => A.ID).where({
      createdBy: req.user.id,
    });

    //If no adopter found, then create new adopter
    if (!result) {
      await INSERT.into(Adopters).entries({
        name: name,
        address: address,
        phone: phone,
        email: email,
      });
      const { ID } = await SELECT.one(Adopters, (A) => A.ID).where({
        createdBy: req.user.id,
      });

      return ID;
    } else {
      const { ID } = result;

      if (update) {
        await UPDATE.entity(Adopters)
          .with({
            email: email,
            phone: phone,
            address: address,
          })
          .where({ ID: ID });
      }

      return ID;
    }
  }
};
