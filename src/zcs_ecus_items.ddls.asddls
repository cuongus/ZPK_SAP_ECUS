@EndUserText.label: 'Custom CDS for ECUS Items'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_APP_ECUS_DATA'
            }
    }
@Metadata.allowExtensions: true
@Search.searchable: true
define custom entity zcs_ecus_items
  // with parameters parameter_name : parameter_type
{
      @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity             : { name: 'I_BillingDocumentStdVH', element: 'BillingDocument' }
      }]
  key BillingDocument      : zde_vbeln_vf; //Pro-Forma Invoice
  key BillingDocumentItem  : abap.numc( 6 );
      PONo                 : abap.char(255);
      CustomerPO           : abap.char(255);
      CustomerItemNoStyle  : abap.char(255);
      CommoditySKU         : abap.char(255);
      HSCODE               : abap.char(255);
      LotNo                : abap.char(255);
      SalesDocument        : abap.char(10);
      SalesDocumentItem    : abap.numc( 6 );
      OutboundDelivery     : abap.char(10);
      OutboundDeliveryitem : abap.numc( 6 );
      MaterialNumber       : abap.char(255);
      MaterialDescription  : abap.char(255);
      BillingQuantity      : abap.dec(18,3);
      QuantityCTNS         : abap.dec(18,3);
      BaseUnitofMeasure    : abap.char(10);
      NumberOfBoxes        : abap.dec(10,0); //Số thùng CTNS
      PALLET               : abap.dec(10,0);
      Gweight              : abap.dec(18,3);
      Nweight              : abap.dec(18,3);
      CARTONSIZE           : abap.char(100);
      BAGSIZE              : abap.char(100);

      CBM                  : abap.dec(18,5);
      ContainerNo          : abap.char(50);  //Số Container
      ContainerSealNo      : abap.char(50);  //Số chì
      TypePTVT             : abap.char(50);
      QuantityPTVT         : abap.string;
      typeXquanPTVT        : abap.string;
      UNITPRICEFOB         : abap.dec(24,5);
      AMOUNT               : abap.dec(24,3);
      PH_Sales2            : abap.char(100);
      ItemSize             : abap.char(255); //Kích thước hàng
      TypeofContainers     : abap.char(100);
      VerifiedGWeight      : abap.dec( 18, 3 );
      CINoStyleNoChange    : abap.char(255);
      CommodityNoChange    : abap.char(225);
      Remarks              : abap.char(255);
      SortItemPackingList  : abap.numc( 6 ); // Sắp xếp item packing list
      TareWeight           : abap.dec(18,5); 

      /* --Association-- */
      _ECUSHeader          : association to parent zcs_ecus_header on $projection.BillingDocument = _ECUSHeader.BillingDocument;

}
