@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZRAP_MAPP_MAHQ'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZRAP_C_MAPP_MAHQ
  provider contract transactional_query
  as projection on ZRAP_R_MAPP_MAHQ
  association [1..1] to ZRAP_R_MAPP_MAHQ as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
      @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity                       : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
      }]
      @Consumption.filter            : { mandatory:  true}
      CompanyCode,
      CompanyCodeName,
      MaHaiQuan,
      TenMaHaiQuan,
      MaHangSAP,
      TenMaHangSAP,
      @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity                       : { name: 'ZI_HINHTHUC_STD_VH', element: 'HinhThuc' }
      }]
      HinhThuc,
      @Semantics: {
        user.createdBy: true
      }
      CreatedBy,
      @Semantics: {
        systemDateTime.createdAt: true
      }
      CreatedAt,
      @Semantics: {
        user.localInstanceLastChangedBy: true
      }
      LocalLastChangedBy,
      @Semantics: {
        systemDateTime.localInstanceLastChangedAt: true
      }
      LocalLastChangedAt,
      @Semantics: {
        systemDateTime.lastChangedAt: true
      }
      LastChangedAt,
      _BaseEntity
}
