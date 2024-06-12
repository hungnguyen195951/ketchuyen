@EndUserText.label: 'Mapping tài khoản kết chuyển cuối kỳ'
@AccessControl.authorizationCheck: #CHECK
define view entity ZFI_I_MAPKC
  as select from zfi_tb_mapkc
  association [0..1] to I_CompanyCode        as _CompanyCode         on $projection.Companycode = _CompanyCode.CompanyCode
  association [0..1] to zfi_i_rulekc         as _RuleKC              on $projection.Rulty = _RuleKC.zrule
  association        to parent ZFI_I_MAPKC_S as _KetChuyenMappingSin on $projection.SingletonID = _KetChuyenMappingSin.SingletonID
{
      @Consumption.valueHelpDefinition: [
      { entity:  { name:    'I_CompanyCodeStdVH',
                   element: 'CompanyCode' }
      }]
      @ObjectModel.foreignKey.association: '_CompanyCode'
  key companycode as Companycode,
      @Consumption.valueHelpDefinition: [{ entity:  { name: 'zfi_i_rulekc', element: 'zrule' } }]
      @ObjectModel.foreignKey.association: '_RuleKC'
      @ObjectModel.text.element:[ '_RuleKC.zrule_des' ]
  key rulty       as Rulty,
      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_GLACCOUNTINCHARTOFACCOUNTS',
                     element: 'GLAccount' }
        }]
  key sacct       as Sacct,
      @Consumption.valueHelpDefinition: [
      { entity:  { name:    'I_GLACCOUNTINCHARTOFACCOUNTS',
                   element: 'GLAccount' }
      }]
      dacct       as Dacct,
      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_COSTCENTER', element: 'CostCenter' }
      }]
      dcost       as Dcost,
      @Consumption.valueHelpDefinition: [
      { entity:  { name:    'I_GLACCOUNTINCHARTOFACCOUNTS',
               element: 'GLAccount' }
      }]
      oacct       as Oacct,
      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_COSTCENTER', element: 'CostCenter' }
      }]
      ocost       as Ocost,
      upd_by      as UpdBy,
      upd_at      as UpdAt,
      1           as SingletonID,
      _KetChuyenMappingSin,
      _CompanyCode,
      _RuleKC

}
