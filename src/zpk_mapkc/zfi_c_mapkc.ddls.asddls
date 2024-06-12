@EndUserText.label: 'Maintain Mapping tài khoản kết chuyển'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZFI_C_MAPKC
  as projection on ZFI_I_MAPKC
{


  key Companycode,
  key Rulty,
  key Sacct,
      Dacct,
      Dcost,
      Oacct,
      Ocost,
      //      UpdBy,
      //      UpdAt,
      @Consumption.hidden: true
      SingletonID,
      _KetChuyenMappingSin : redirected to parent ZFI_C_MAPKC_S

}
