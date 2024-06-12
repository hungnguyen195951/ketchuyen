@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Rule kết chuyển'
define view entity zfi_i_rulekc
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDO_RULTY' )
{
  key domain_name,
  key value_position,
      @Semantics.language: true
  key language,
      @ObjectModel.text.element:[ 'zrule_des' ]
      value_low as zrule,
      text      as zrule_des
}
