@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Kết chuyển (Raw data)'
@Metadata.allowExtensions: true
define root view entity ZFI_I_KC_FINAL
  with parameters
    P_CompanyCode  : bukrs,
    @Environment.systemField: #SYSTEM_DATE
    P_FiscalYear   : gjahr,
    P_FiscalPeriod : fins_fiscalperiod,
    P_RuleType     : zde_rulty
  as select from    zfi_i_kc_raw( P_CompanyCode : $parameters.P_CompanyCode,
                              P_FiscalYear : $parameters.P_FiscalYear,
                              P_FiscalPeriod : $parameters.P_FiscalPeriod,
                              P_RuleType : $parameters.P_RuleType ) as currentBal

    left outer join zfi_i_dockc_current( P_CompanyCode : $parameters.P_CompanyCode,
                              P_FiscalYear : $parameters.P_FiscalYear,
                              P_FiscalPeriod : $parameters.P_FiscalPeriod,
                              P_RuleType : $parameters.P_RuleType ) as _CurrentDocKC on  _CurrentDocKC.Companycode = currentBal.CompanyCode
                                                                                     and _CurrentDocKC.Rulty       = currentBal.rulty
                                                                                     and _CurrentDocKC.Fiscalyear  = currentBal.FiscalYear
                                                                                     and _CurrentDocKC.Period      = currentBal.FiscalPeriod
  //    left outer join ZFI_I_KC_BEGINBAL( P_CompanyCode : $parameters.P_CompanyCode,
  //                                       P_FiscalYear : $parameters.P_FiscalYear,
  //                                       P_FiscalPeriod : $parameters.P_FiscalPeriod ) as beginBalance  on  beginBalance.FiscalYear   = currentBal.FiscalYear
  //                                                                                                      and beginBalance.FiscalPeriod = currentBal.FiscalPeriod
  //                                                                                                      and beginBalance.CompanyCode  = currentBal.CompanyCode
  //                                                                                                      and beginBalance.GLAccount    = currentBal.GLAccount

{

  key    currentBal.GLAccount,
  key    currentBal.rulty                                                                             as RuleType,
  key    currentBal.FiscalPeriod,
  key    currentBal.FiscalPeriodStartDate,
  key    currentBal.FiscalPeriodEndDate,
  key    currentBal.FiscalYear,
  key    currentBal.CompanyCode,
         currentBal.rule_des                                                                          as RuleTypeDes,
         currentBal.dacct                                                                             as TargetAccount,
         currentBal.dcost                                                                             as TargetCostCenter,
         currentBal.oacct                                                                             as OffsettingAccount,
         currentBal.ocost                                                                             as OffsettingCostCenter,
         currentBal.CompanyCodeCurrency,
         @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
         currentBal.DebitAmountInCoCodeCrcy,
         @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
         currentBal.CreditAmountInCoCodeCrcy,
         @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
         @DefaultAggregation: #SUM
         ( abs( $projection.debitamountincocodecrcy ) - abs( $projection.creditamountincocodecrcy ) ) as TotalAmtInCoCodeCrcy,
         _CurrentDocKC.Belnr                                                                          as ChungTuKetChuyen,
         case when $projection.ChungTuKetChuyen is not null and $projection.ChungTuKetChuyen is not initial then 3 //complete
         else 0 // not complete
         end                                                                                          as StatusCritical,
         case when $projection.ChungTuKetChuyen is not null and $projection.ChungTuKetChuyen is not initial then 'Complete' //complete
              else  'Not been processed'// not complete
         end                                                                                          as Status
         //         @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
         //         beginBalance.DebitAmountInCoCodeCrcy                                                                                    as beginDebitAmountInCoCodeCrcy,
         //         @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
         //         beginBalance.CreditAmountInCoCodeCrcy                                                                                   as beginCreditAmountInCoCodeCrcy,
         //         @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
         //         ( beginBalance.DebitAmountInCoCodeCrcy + beginBalance.CreditAmountInCoCodeCrcy  )                                       as AmtInBeginCoCodeTransCrcy,
         //         @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
         //         @DefaultAggregation: #SUM
         //         ( $projection.AmtInBeginCoCodeTransCrcy + $projection.debitamountincocodecrcy + $projection.creditamountincocodecrcy  ) as TotalAmtInCoCodeCrcy
}
