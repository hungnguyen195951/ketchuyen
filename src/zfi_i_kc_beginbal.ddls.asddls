@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Kết chuyển (Raw data)'
define view entity ZFI_I_KC_BEGINBAL
  with parameters
    P_CompanyCode  : bukrs,
    P_FiscalYear   : gjahr,
    P_FiscalPeriod : fins_fiscalperiod
  as select from I_FiscalYearPeriod
    inner join   I_GLAccountLineItem on I_GLAccountLineItem.PostingDate      < I_FiscalYearPeriod.FiscalPeriodStartDate
{
  key I_FiscalYearPeriod.FiscalPeriod,
  key I_FiscalYearPeriod.FiscalYear,
  key I_GLAccountLineItem.CompanyCode,
  key I_GLAccountLineItem.GLAccount,
      I_FiscalYearPeriod.FiscalPeriodStartDate,
      I_GLAccountLineItem.CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( I_GLAccountLineItem.DebitAmountInCoCodeCrcy )  as DebitAmountInCoCodeCrcy,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( I_GLAccountLineItem.CreditAmountInCoCodeCrcy ) as CreditAmountInCoCodeCrcy
}
where
      I_GLAccountLineItem.SourceLedger     = '0L'
  and I_GLAccountLineItem.Ledger           = '0L'
  and I_FiscalYearPeriod.FiscalYearVariant = 'K1'
  and I_FiscalYearPeriod.FiscalPeriod      = $parameters.P_FiscalPeriod
  and I_FiscalYearPeriod.FiscalYear        = $parameters.P_FiscalYear
  and I_GLAccountLineItem.CompanyCode      = $parameters.P_CompanyCode
group by
  I_FiscalYearPeriod.FiscalPeriod,
  I_FiscalYearPeriod.FiscalYear,
  I_GLAccountLineItem.CompanyCode,
  I_GLAccountLineItem.GLAccount,
  I_GLAccountLineItem.CompanyCodeCurrency,
  I_FiscalYearPeriod.FiscalPeriodStartDate
