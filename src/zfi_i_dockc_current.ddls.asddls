@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Chứng từ kết chuyện hiện tại'
define root view entity zfi_i_dockc_current
  with parameters
    P_CompanyCode  : bukrs,
    P_FiscalYear   : gjahr,
    P_FiscalPeriod : fins_fiscalperiod,
    P_RuleType     : zde_rulty
  as select from zfi_tb_kc
{
  key companycode as Companycode,
  key period      as Period,
  key fiscalyear  as Fiscalyear,
  key rulty       as Rulty,
  key belnr       as Belnr,
      postingdate as PostingDate,
      pst_user    as PstUser,
      pst_date    as PstDate
}
where
      iscan                 is initial
  and zfi_tb_kc.companycode = $parameters.P_CompanyCode
  and zfi_tb_kc.fiscalyear  = $parameters.P_FiscalYear
  and zfi_tb_kc.period      = $parameters.P_FiscalPeriod
  and zfi_tb_kc.rulty       = $parameters.P_RuleType
