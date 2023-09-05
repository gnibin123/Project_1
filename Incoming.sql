SET COLSEP ","
SET PAGESIZE 0
SET FEEDBACK OFF
SET HEADING ON

SPOOL result_output.csv

SELECT
    to_char(a.rcvd_at, 'MM/DD/YYYY HH:MI:SS AM')                                  calendardate,
    JSON_VALUE(f.msg_str, '$.ChannelRefId')                                       transactionnumber,
    nvl(decode(c.transaction_type_code,
           NULL,
           substr(c.regulatory_report, 15, 3),
           c.transaction_type_code),substr(b.TRAIL,instr(b.TRAIL, '<<', 1)+2,  
    instr(substr(b.TRAIL, instr(b.TRAIL, '<<', 1)+2), '>>', 1)-1) )                                               transactionpurpose,
    (
        SELECT
            description
        FROM
            enrich.ip_cb_txn_type_code
        WHERE
            txn_type_code = nvl(decode(c.transaction_type_code,
           NULL,
           substr(c.regulatory_report, 15, 3),
           c.transaction_type_code),substr(b.TRAIL,instr(b.TRAIL, '<<', 1)+2,  
    instr(substr(b.TRAIL, instr(b.TRAIL, '<<', 1)+2), '>>', 1)-1) )      

 

    )                                                                             transactionpurposedescription,
    c.benef_inst_party_id                                                         accountbusinesskey,
    c.instructed_currency                                                         currencybusinesskey,
    c.value_currency                                                              settlementcurrency,
    NULL                                                                          channelbusinesskey,
    'Incoming'                                                                    transactiontypebusinesskey,
    'International'                                                               transfertype,
    'SWIFT'                                                                       subcategory,
    b.msg_type                                                                    transactionmessagetype,
    c.remittance_info                                                             transactionreasontypecode,
    to_char(a.rcvd_at, 'MM/DD/YYYY HH:MI:SS AM')                                  transactioneffectivestarttimestamp,
    to_char(decode(f.msg_type, 'ACC-2', f.submitted_at, NULL),
            'MM/DD/YYYY HH:MI:SS AM')                                             transactioneffectiveendtimestamp,
    to_char(decode(f.msg_type, 'ACC-2', f.submitted_at, NULL),
            'MM/DD/YYYY HH:MI:SS AM')                                             transactionposteddate,
    c.value_date                                                                  transactionvaluedate,
    extractvalue(xml_data_str, '/customTag/ExchangeRate/value')                   transactionbookrate,
    c.sett_amount                                                                 transactioncurrencyamount,
    extractvalue(xml_data_str, '/customTag/bankChargeAmt/value')                  transactionfeeamount,
    NULL                                                                          transactiondebitamount,
    c.ord_cust_acc                                                                contracustomeraccountnumber,
    coalesce(ord_cust_na, ord_cust_na1, ord_cust_na2, ord_cust_na3, ord_cust_na4) contracustomeraccountname,
    ( substr(decode(c.ord_cust_bic,
                    NULL,
                    decode(c.order_inst_bic, NULL, b.sender, c.order_inst_bic),
                    c.ord_cust_bic),
             5,
             2) )                                                                          contracustomercountry,
    NULL                                                                          contracustomeraddress,
    NULL                                                                          contracustomerbankname,
    NULL                                                                          contracustomerbankaddress,
    ( decode(c.ord_cust_bic,
             NULL,
             decode(c.order_inst_bic, NULL, b.sender, c.order_inst_bic),
             c.ord_cust_bic) )                                                             contracustomerbankbic,
    b.status                                                                      transactionstatuscode,
    c.sender_ref                                                                  transactionbusinesskey,
    f.msg_str,
    NULL                                                                          userid,
    b.appln_code,
    NULL                                                                          exchangeratespecial
FROM
    ims_mm.mymt_in_repository  a,
    ims_mm.mymt_out_repository b,
    ims_mm.mymt_out_msgs       f,
    ims_mm.pa_103_dtls         c
WHERE
        a.in_msg_id (+) = b.in_msg_id
    AND b.out_msg_id = c.out_msg_id
    AND b.out_msg_id = f.out_msg_id
    AND b.msg_dtl_id = c.msg_dtl_id
    AND f.msg_type = 'ACC-2'
    AND f.status = 'DELIVERED_ACS'
    AND b.status = 'TRANSMITTED'
    AND f.appln_code = 'PA'
    AND a.rcvd_at >= TO_DATE('2023-07-01', 'YYYY-MM-DD') 
    AND a.rcvd_at < TO_DATE('2023-07-31', 'YYYY-MM-DD'));
SPOOL OFF	