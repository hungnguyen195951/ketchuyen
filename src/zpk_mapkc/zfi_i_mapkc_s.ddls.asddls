@EndUserText.label: 'Mapping tài khoản kết chuyển cuối kỳ'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZFI_I_MAPKC_S
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZFI_I_MAPKC'
  composition [0..*] of ZFI_I_MAPKC as _KetChuyenMapping
{
  key 1 as SingletonID,
  _KetChuyenMapping,
  I_CstmBizConfignLastChgd.LastChangedDateTime as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
