@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Chứng từ kết chuyển'
@Metadata.allowExtensions: true
define root view entity zfi_i_doc_kc
  as select from zfi_tb_kc
{
  key companycode as Companycode,
  key period      as Period,
  key fiscalyear  as Fiscalyear,
  key rulty       as Rulty,
  key belnr       as Belnr,
      postingdate as Postingdate,
      pst_user    as PstUser,
      pst_date    as PstDate,
      iscan       as Iscan,
      can_user    as CanUser,
      can_date    as CanDate
}
