@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Kết chuyển (Raw data)'
define view entity zfi_i_kc_raw
  with parameters
    P_CompanyCode  : bukrs,
    P_FiscalYear   : gjahr,
    P_FiscalPeriod : fins_fiscalperiod,
    P_RuleType     : zde_rulty
  as select from    I_FiscalYearPeriod
    inner join      I_GLAccountLineItem               on  I_GLAccountLineItem.FiscalYear       = I_FiscalYearPeriod.FiscalYear
                                                      and I_FiscalYearPeriod.FiscalYearVariant = 'K1'
                                                      and I_FiscalYearPeriod.FiscalPeriod      = $parameters.P_FiscalPeriod
                                                      and I_FiscalYearPeriod.FiscalYear        = $parameters.P_FiscalYear
                                                      and I_GLAccountLineItem.CompanyCode      = $parameters.P_CompanyCode
    left outer join I_OperationalAcctgDocItem as bseg on  bseg.AccountingDocument     = I_GLAccountLineItem.AccountingDocument
                                                      and bseg.AccountingDocumentItem = I_GLAccountLineItem.AccountingDocumentItem
                                                      and bseg.CompanyCode            = I_GLAccountLineItem.CompanyCode
    inner join      ZFI_i_MAPKC_2             as sourceAccount    on  sourceAccount.companycode = I_GLAccountLineItem.CompanyCode
                                                                  and sourceAccount.sacct       = I_GLAccountLineItem.GLAccount
                                                                  and sourceAccount.rulty       = $parameters.P_RuleType
  //    inner join ZFI_I_KC_BEGINBAL( P_CompanyCode : $parameters.P_CompanyCode,
  //                                  P_FiscalYear : $parameters.P_FiscalYear,
  //                                  P_FiscalPeriod : $parameters.P_FiscalPeriod ) as beginBalance
  //                                  on beginBalance.FiscalYear = I_GLAccountLineItem.FiscalYear
  //                                 and beginBalance.FiscalPeriod = I_FiscalYearPeriod.FiscalPeriod
  //                                 and beginBalance.CompanyCode = I_GLAccountLineItem.CompanyCode
  //                                 and beginBalance.GLAccount = I_GLAccountLineItem.GLAccount

{
      //  cast( concat( concat($parameters.P_FiscalYear , substring($parameters.P_FiscalPeriod, 2, 2) ),  '01' ) as abap.dats ) as firstdayofcurrentperiod,
      //  dats_add_days( $projection.firstdayofcurrentperiod, -1 , 'INITIAL' )                                                  as lastdayoflastperiod,
      //  dats_add_days( dats_add_months( $projection.firstdayofcurrentperiod, 1 , 'INITIAL' ), -1, 'INITIAL' )                 as lastdayofcurrentperiod,
  key I_FiscalYearPeriod.FiscalPeriod,
  key I_FiscalYearPeriod.FiscalPeriodStartDate,
  key I_FiscalYearPeriod.FiscalPeriodEndDate,
  key I_GLAccountLineItem.FiscalYear,
  key I_GLAccountLineItem.CompanyCode,
  key I_GLAccountLineItem.GLAccount,
  key sourceAccount.rulty,
      sourceAccount.rule_des,
      sourceAccount.dacct,
      sourceAccount.dcost,
      sourceAccount.oacct,
      sourceAccount.ocost,
      I_GLAccountLineItem.CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case when bseg.IsNegativePosting = 'X' then I_GLAccountLineItem.CreditAmountInCoCodeCrcy
                else I_GLAccountLineItem.DebitAmountInCoCodeCrcy
           end )                                          as DebitAmountInCoCodeCrcy,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
       sum( case when bseg.IsNegativePosting = 'X' then I_GLAccountLineItem.DebitAmountInCoCodeCrcy
                else I_GLAccountLineItem.CreditAmountInCoCodeCrcy
           end )                                          as CreditAmountInCoCodeCrcy
}
where
        I_GLAccountLineItem.SourceLedger =  '0L'
  and   I_GLAccountLineItem.Ledger       =  '0L'
  and(
        I_GLAccountLineItem.PostingDate  >= I_FiscalYearPeriod.FiscalPeriodStartDate
    and I_GLAccountLineItem.PostingDate  <= I_FiscalYearPeriod.FiscalPeriodEndDate
  )
group by
  I_FiscalYearPeriod.FiscalPeriod,
  I_FiscalYearPeriod.FiscalPeriodStartDate,
  I_FiscalYearPeriod.FiscalPeriodEndDate,
  I_GLAccountLineItem.FiscalYear,
  I_GLAccountLineItem.CompanyCode,
  I_GLAccountLineItem.GLAccount,
  sourceAccount.rulty,
  sourceAccount.rule_des,
  I_GLAccountLineItem.CompanyCodeCurrency,
  sourceAccount.dacct,
  sourceAccount.dcost,
  sourceAccount.oacct,
  sourceAccount.ocost
