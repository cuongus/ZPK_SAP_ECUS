@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZRAP_KB_MAHQ'
}
@AccessControl.authorizationCheck: #MANDATORY
@Search.searchable: true
define root view entity ZRAP_C_KB_MAHQ
  provider contract transactional_query
  as projection on ZRAP_R_KB_MAHQ
  association [1..1] to ZRAP_R_KB_MAHQ as _BaseEntity on $projection.UUID = _BaseEntity.UUID
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
