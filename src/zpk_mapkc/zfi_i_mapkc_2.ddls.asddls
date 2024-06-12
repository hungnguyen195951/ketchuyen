@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Source GL Account for KC'
define view entity ZFI_i_MAPKC_2
  as select from zfi_tb_mapkc
    inner join   zfi_i_rulekc on zfi_i_rulekc.zrule = zfi_tb_mapkc.rulty
{
  key zfi_tb_mapkc.companycode,
  key zfi_tb_mapkc.rulty,
  key zfi_tb_mapkc.sacct,
      zfi_i_rulekc.zrule_des as rule_des,
      zfi_tb_mapkc.dacct,
      zfi_tb_mapkc.dcost,
      zfi_tb_mapkc.oacct,
      zfi_tb_mapkc.ocost
}
