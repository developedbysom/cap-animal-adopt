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
