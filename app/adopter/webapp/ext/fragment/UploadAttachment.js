sap.ui.define(
  [
    "sap/m/MessageToast",
    "sap/ui/core/Item",
    "sap/ui/model/Filter",
    "sap/ui/model/FilterOperator",
  ],
  function (MessageToast, Item, Filter, FilterOperator) {
    "use strict";

    return {
      onBeforeUploadStarts: async function (oEvent) {
        debugger;
        const model = this.getModel();
        const item = oEvent.getParameters().item;
        const uploader = this.byId("uploadSetPlugin")._getActiveUploader();
        const serviceUrl = model.getServiceUrl().replace(/\/$/, "");
        const path = this.getRouting().getView().getBindingContext()?.getPath();

        const binding = model.bindList(`${path}/mediaFile`);
        const oFile = oEvent.getParameter("item").getFileObject();

        const attachment = binding.create({
          fileName: item.getFileName(),
          mediaType: item.getProperty("mediaType"),
        });
        item.setUploadUrl(`${serviceUrl}${path}/mediaFile`);

        await attachment.created();

        item.setUploadState("Ready");

        item.setUploadUrl(
          `${serviceUrl}${path}/mediaFile('${
            attachment.getObject().ID
          }')/content`
        );
        item.addHeaderField(
          new Item({
            key: "X-CSRF-Token",
            text: model.getHttpHeaders()["X-CSRF-Token"],
          })
        );

        uploader.uploadItem(item);
      },
      onUploadCompleted: function (oEvent) {
        debugger;
        const oTable = this.byId("table-uploadSet");
        const oModel = oTable.getModel();
        const iResponseStatus = oEvent.getParameter("status");

        if (iResponseStatus === 204) {
          const { ID: animal_ID } = oTable.getBindingContext().getValue();
          if (animal_ID) {
            const aFilters = [];
            aFilters.push(
              new Filter("animal_ID", FilterOperator.EQ, animal_ID)
            );
            const oBinding = oTable.getBinding("items");
            oBinding.filter(aFilters);
            oModel.refresh();

            MessageToast.show("Document Added");

            aFilters.pop();
            oBinding.filter(aFilters);
          }
        }
      },
    };
  }
);
