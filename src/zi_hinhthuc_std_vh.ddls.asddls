@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for Hình thức'
@Search.searchable: true
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
//@ObjectModel.usageType:{
//    serviceQuality: #X,
//    sizeCategory: #S,
//    dataClass: #MIXED
//}
define view entity ZI_HINHTHUC_STD_VH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDO_HINHTHUC' )
{
      @UI.lineItem: [{ position: 10, importance: #HIGH }]
      @UI.hidden: true
  key domain_name,
      @UI.hidden: true
      @UI.lineItem: [{ position: 20, importance: #MEDIUM }]
  key value_position,
      @UI.lineItem: [{ position: 30, importance: #MEDIUM }]
      @Semantics.language: true
      @UI.hidden: true
  key language,
      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 40, importance: #HIGH, label: 'Characteristic Id' }]
      @UI.identification: [{ label: 'Characteristic Id' }]
      @UI.textArrangement: #TEXT_ONLY
      @ObjectModel.text.element: ['Description']
      @EndUserText.label: 'Value'
      value_low as HinhThuc,
      @UI.lineItem: [{ position: 50, importance: #MEDIUM, label: 'Hình thức' }]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      @EndUserText.label: 'Description'
      text      as Description
}
