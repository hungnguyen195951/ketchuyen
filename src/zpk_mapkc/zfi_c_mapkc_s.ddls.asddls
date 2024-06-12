@EndUserText.label: 'Maintain Mapping tài khoản kết chuyển cu'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity ZFI_C_MAPKC_S
  provider contract transactional_query
  as projection on ZFI_I_MAPKC_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _KetChuyenMapping : redirected to composition child ZFI_C_MAPKC
  
}
