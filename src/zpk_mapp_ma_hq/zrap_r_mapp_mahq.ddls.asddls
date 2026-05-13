@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZRAP_MAPP_MAHQ'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZRAP_R_MAPP_MAHQ
  as select from zrap_mapp_mahq as Mapping_Ma_HQ
{
  key uuid                  as UUID,
  @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity                       : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
      }]
      @Consumption.filter            : { mandatory:  true}
      companycode           as CompanyCode,
      companycodename       as CompanyCodeName,
      ma_hai_quan           as MaHaiQuan,
      ten_ma_hai_quan       as TenMaHaiQuan,
      ma_hang_sap           as MaHangSAP,
      ten_ma_hang_sap       as TenMaHangSAP,
      @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity                       : { name: 'ZI_HINHTHUC_STD_VH', element: 'HinhThuc' }
      }]
      hinh_thuc             as HinhThuc,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt
}
