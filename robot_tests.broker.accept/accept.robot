*** Settings ***
Library  Selenium2Library
Library  accept_service.py
Library   Collections
Library   DateTime
Library   String

*** Variables ***
${Кнопка "Вхід"}  xpath=  /html/body/app-shell/md-content/app-content/div/div[2]/div[2]/div/div/md-content/div/div[2]/div[1]/div[2]/div/login-panel/div/div/button
${Кнопка "Мої закупівлі"}  xpath=  /html/body/app-shell/md-toolbar[1]/app-header/div[1]/div[4]/div[1]/sub-menu/div/div[1]/div/div[1]/a
${Кнопка "Створити"}  xpath=  .//a[@ui-sref='root.dashboard.tenderDraft({id:0})']
${Поле "Процедура закупівлі"}  xpath=  //div[@class='TenderEditPanel TenderDraftTabsContainer']//*[@id="procurementMethodType"]
${Поле "Узагальнена назва закупівлі"}  id=  title
${Поле "Узагальнена назва лоту"}  id=  lotTitle-0
${Поле "Конкретна назва предмета закупівлі"}  id=  itemDescription--
${Поле "Процедура закупівлі" варіант "Переговорна процедура"}  xpath=  //div [@class='md-select-menu-container md-active md-clickable']//md-select-menu [@class = '_md']//md-content [@class = '_md']//md-option[5]
${Вкладка "Лоти закупівлі"}  xpath=  /html/body/app-shell/md-content/app-content/div/div[2]/div[2]/div/div/div/md-content/div/form/div/div/md-content/ng-transclude/md-tabs/md-tabs-wrapper/md-tabs-canvas/md-pagination-wrapper/md-tab-item[2]
${Кнопка "Опублікувати"}  id=  tender-publish
${Кнопка "Так" у попап вікні}  xpath=  /html/body/div[1]/div/div/div[3]/button[1]
${Посилання на тендер}  id=  tenderUID
${Кнопка "Зберегти учасника переговорів"}  id=  tender-create-award
${Поле "Ціна пропозиції"}  id=  award-value-amount
${Поле "Тип документа" (Кваліфікація учасників)}  id=  type-award-document

*** Keywords ***
Підготувати клієнт для користувача
  [Arguments]     @{ARGUMENTS}
  [Documentation]  Відкрити брaвзер, створити обєкт api wrapper, тощо
  Open Browser  ${USERS.users['${ARGUMENTS[0]}'].homepage}  ${USERS.users['${ARGUMENTS[0]}'].browser}  alias=${ARGUMENTS[0]}
  maximize browser window
  Login   ${ARGUMENTS[0]}

Login
  [Arguments]  @{ARGUMENTS}
  wait until element is visible  ${Кнопка "Вхід"}    60
  Click Button    ${Кнопка "Вхід"}
  wait until element is visible  id=username         60
  Input text      id=username          ${USERS.users['${ARGUMENTS[0]}'].login}
  Input text      id=password          ${USERS.users['${ARGUMENTS[0]}'].password}
  Click Button    id=loginButton

Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${items}

    log to console  *
    log to console  Починаємо "Підготувати дані для оголошення тендера"
    ${TENDER_TYPE}=  convert to string  complaints
    set global variable  ${TENDER_TYPE}

    log to console  *
    log to console  ${TENDER_TYPE}
    log to console  *

    run keyword and ignore error  Отримати тип процедури закупівлі  ${tender_data}
    run keyword if  '${TENDER_TYPE}' == 'negotiation'            Підготувати тендер дату   ${tender_data}
    run keyword if  '${TENDER_TYPE}' == 'aboveThresholdUA'       Підготувати тендер дату   ${tender_data}
    run keyword if  '${TENDER_TYPE}' == 'aboveThresholdEU'       Підготувати тендер дату   ${tender_data}

    log to console  *
    log to console  ${TENDER_TYPE}
    log to console  *

    log to console  закінчили "Підготувати дані для оголошення тендера"
    [return]    ${tender_data}

Отримати тип процедури закупівлі
  [Arguments]  ${tender_data}
  ${TENDER_TYPE}=  convert to string  ${tender_data.data.procurementMethodType}
  set global variable  ${TENDER_TYPE}


Підготувати тендер дату
  [Arguments]  ${tender_data}
  ${tender_data}=       adapt_data         ${tender_data}
  set global variable  ${tender_data}

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
  run keyword if  '${TENDER_TYPE}' == 'negotiation'        Створити тендер negotiation  @{ARGUMENTS}
  run keyword if  '${TENDER_TYPE}' == 'complaints'          Створити тендер complaints   @{ARGUMENTS}

  [return]  ${TENDER_UA}


Створити тендер complaints
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...      ${ARGUMENTS[0]} ==  username
    ...      ${ARGUMENTS[1]} ==  tender_data
    log to console  *
    log to console  починаємо "Створити тендер complaints"

    ${title}=                             Get From Dictionary             ${ARGUMENTS[1].data}                        title
    ${description}=                       Get From Dictionary             ${ARGUMENTS[1].data}                        description
    ${vat}=                               get from dictionary             ${ARGUMENTS[1].data.value}                  valueAddedTaxIncluded
    ${currency}=                          Get From Dictionary             ${ARGUMENTS[1].data.value}                  currency

    ${lots}=                              Get From Dictionary             ${ARGUMENTS[1].data}                        lots
    ${lot_description}=                   Get From Dictionary             ${lots[0]}                                  description
    ${lot_title}=                         Get From Dictionary             ${lots[0]}                                  title
    ${lot_amount_str}=                    convert to string               ${ARGUMENTS[1].data.lots[0].value.amount}
    ${lot_minimal_step_amount}=           get from dictionary             ${lots[0].minimalStep}                      amount
    ${lot_minimal_step_amount_str}=       convert to string               ${lot_minimal_step_amount}

    ${items}=                             Get From Dictionary             ${ARGUMENTS[1].data}                        items
    ${item_description}=                  Get From Dictionary             ${items[0]}                                 description
    # Код CPV
    ${item_scheme}=                       Get From Dictionary             ${items[0].classification}                  scheme
    ${item_id}=                           Get From Dictionary             ${items[0].classification}                  id
    ${item_descr}=                        Get From Dictionary             ${items[0].classification}                  description

    #Код ДК
    run keyword and ignore error  Отримуємо код ДК  ${ARGUMENTS[1]}

    ${item_quantity}=                     Get From Dictionary             ${items[0]}                                 quantity
    ${item_unit}=                         Get From Dictionary             ${items[0].unit}                            name
    #адреса поставки
    ${item_streetAddress}=                Get From Dictionary             ${items[0].deliveryAddress}                 streetAddress
    ${item_locality}=                     Get From Dictionary             ${items[0].deliveryAddress}                 locality
    ${item_region}=                       Get From Dictionary             ${items[0].deliveryAddress}                 region
    ${item_postalCode}=                   Get From Dictionary             ${items[0].deliveryAddress}                 postalCode
    ${item_countryName}=                  Get From Dictionary             ${items[0].deliveryAddress}                 countryName

    #період уточнень
    ${enquiryPeriod_startDate}=           Get From Dictionary             ${ARGUMENTS[1].data.enquiryPeriod}          startDate
    ${enquiryPeriod_endDate}=             Get From Dictionary             ${ARGUMENTS[1].data.enquiryPeriod}          endDate

    #період подачі пропозицій
    ${tenderPeriod_startDate}=            Get From Dictionary             ${ARGUMENTS[1].data.tenderPeriod}           startDate
    ${tenderPeriod_endDate}=              Get From Dictionary             ${ARGUMENTS[1].data.tenderPeriod}           endDate

    #період доставки
    ${delivery_startDate}=                Get From Dictionary             ${items[0].deliveryDate}                    startDate
    ${delivery_endDate}=                  Get From Dictionary             ${items[0].deliveryDate}                    endDate

    #конвертація дат та часу
    ${enquiryPeriod_startDate_str}=       convert_datetime_to_new         ${enquiryPeriod_startDate}
	${enquiryPeriod_startDate_time}=      convert_datetime_to_new_time    ${enquiryPeriod_startDate}
    ${enquiryPeriod_endDate_str}=         convert_datetime_to_new         ${enquiryPeriod_endDate}
	${enquiryPeriod_endDate_time}=        convert_datetime_to_new_time    ${enquiryPeriod_endDate}

    ${tenderPeriod_startDate_str}=        convert_datetime_to_new         ${tenderPeriod_startDate}
	${tenderPeriod_startDate_time}=       convert_datetime_to_new_time    ${tenderPeriod_startDate}
    ${tenderPeriod_endDate_str}=          convert_datetime_to_new         ${tenderPeriod_endDate}
	${tenderPeriod_endDate_time}=         convert_datetime_to_new_time    ${tenderPeriod_endDate}

    ${delivery_StartDate_str}=            convert_datetime_to_new         ${delivery_startDate}
	${delivery_StartDate_time}=           convert_datetime_to_new_time    ${delivery_startDate}
    ${delivery_endDate_str}=              convert_datetime_to_new         ${delivery_endDate}
	${delivery_endDate_time}=             convert_datetime_to_new_time    ${delivery_endDate}
    #Контактна особа
	${contact_point_name}=                Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    name
	${contact_point_phone}=               Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    telephone
	${contact_point_fax}=                 Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    faxNumber
	${contact_point_email}=               Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    email

    ${acceleration_mode}=                 Get From Dictionary             ${ARGUMENTS[1].data}                                 procurementMethodDetails

   #клікаєм на "Мій кабінет"
    click element  xpath=(.//span[@class='ng-binding ng-scope'])[3]
    sleep  2
    wait until element is visible  ${Кнопка "Мої закупівлі"}  30
    click element  ${Кнопка "Мої закупівлі"}
    sleep  2
    wait until element is visible  ${Кнопка "Створити"}  30
    click element  ${Кнопка "Створити"}
    sleep  1
    wait until element is visible  ${Поле "Узагальнена назва закупівлі"}  30
    input text  ${Поле "Узагальнена назва закупівлі"}  ${title}
    run keyword if       '${vat}'     click element      id=tender-value-vat
    sleep  1
    input text  id=description  ${description}
    #Заповнюємо дати
    input text  xpath=(.//input[@class='md-datepicker-input'])[1]                       ${enquiryPeriod_startDate_str}
    sleep  2
    input text  xpath=(//*[@id="timeInput"])[1]                                         ${enquiryPeriod_startDate_time}
    sleep  2
    input text  xpath=(.//input[@class='md-datepicker-input'])[2]                       ${enquiryPeriod_endDate_str}
    sleep  2
    input text  xpath=(//*[@id="timeInput"])[2]                                         ${enquiryPeriod_endDate_time}
    sleep  2
    input text  xpath=(.//input[@class='md-datepicker-input'])[3]                       ${tenderPeriod_startDate_str}
    sleep  2
    input text  xpath=(//*[@id="timeInput"])[3]                                         ${tenderPeriod_startDate_time}
    sleep  2
    input text  xpath=(.//input[@class='md-datepicker-input'])[4]                       ${tenderPeriod_endDate_str}
    sleep  2
    input text  xpath=(//*[@id="timeInput"])[4]                                         ${tenderPeriod_endDate_time}
    sleep  2

    #Переходимо на вкладку "Лоти закупівлі"
#    click element  ${Вкладка "Лоти закупівлі"}
    execute javascript  angular.element("md-tab-item")[1].click()
    sleep  2
    wait until element is visible  ${Поле "Узагальнена назва лоту"}  30
    input text      ${Поле "Узагальнена назва лоту"}                                    ${lot_title}
    #заповнюємо поле "Очікувана вартість закупівлі"
    input text      amount-lot-value.0                                                  ${lot_amount_str}
    sleep  1
    #Заповнюємо поле "Примітки"
    input text      lotDescription-0                                                    ${lot_description}
    #Заповнюємо поле "Мінімальний крок пониження ціни"
    input text      amount-lot-minimalStep.0                                            ${lot_minimal_step_amount_str}

    #переходимо на вкладку "Специфікації закупівлі"
    Execute Javascript  $($("app-tender-lot")).find("md-tab-item")[1].click()
    wait until element is visible  ${Поле "Конкретна назва предмета закупівлі"}  30
    input text      ${Поле "Конкретна назва предмета закупівлі"}                        ${item_description}
    input text      id=itemQuantity--                                                   ${item_quantity}
    #Заповнюємо поле "Код ДК 021-2015 "
    Execute Javascript    $($('[id=cpv]')[0]).scope().value.classification = {id: "${item_id}", description: "${item_description}", scheme: "${item_scheme}"};
    sleep  2
    #Заповнюємо додаткові коди
    run keyword and ignore error  Заповнюємо додаткові коди
    sleep  2
    #Заповнюємо поле "Одиниці виміру"
    Select From List  id=unit-unit--  ${item_unit}
    #Заповнюємо датапікери
    input text      xpath=(*//input[@class='md-datepicker-input'])[5]                   ${delivery_StartDate_str}
    sleep  2
    input text      xpath=(//*[@id="timeInput"])[5]                                     ${delivery_StartDate_time}
    sleep  2
    input text      xpath=(.//input[@class='md-datepicker-input'])[6]                   ${delivery_endDate_str}
    sleep  2
    input text      xpath=(//*[@id="timeInput"])[6]                                     ${delivery_endDate_time}
    sleep  2
    #Заповнюємо адресу доставки
    select from list  id=countryName.value.deliveryAddress--                            ${item_countryName}
    input text        id=streetAddress.value.deliveryAddress--                          ${item_streetAddress}
    input text        id=locality.value.deliveryAddress--                               ${item_locality}
    input text        id=region.value.deliveryAddress--                                 ${item_region}
    input text        id=postalCode.value.deliveryAddress--                             ${item_postalCode}
    sleep  2
    # Переходимо на вкладку "Контактна особа"
    Execute Javascript    angular.element("md-tab-item")[3].click()
    sleep  3
    input text            procuringEntityContactPointName                               ${contact_point_name}
    input text            procuringEntityContactPointTelephone                          ${contact_point_phone}
    input text            procuringEntityContactPointFax                                ${contact_point_fax}
    input text            procuringEntityContactPointEmail                              ${contact_point_email}
    input text            procurementMethodDetails                                      ${acceleration_mode}
    input text            submissionMethodDetails                                       quick(mode:fast-forward)
    input text            mode                                                          test
    sleep  3
    click button  tender-apply
    sleep  3
    ${NewTenderUrl}=  Execute Javascript  return window.location.href
    log to console  ******************
    log to console  NewTenderUrl ${NewTenderUrl}
    SET GLOBAL VARIABLE  ${NewTenderUrl}
    sleep  4
    wait until element is visible  ${Поле "Узагальнена назва закупівлі"}  30
    click button  ${Кнопка "Опублікувати"}
    wait until element is visible  ${Кнопка "Так" у попап вікні}  60
    click element  ${Кнопка "Так" у попап вікні}
    wait until element is visible  xpath=//div[contains(text(),'Опубліковано')]  300
    ${localID}=    get_local_id_from_url        ${NewTenderUrl}
    ${hrefToTender}=    Evaluate    "/dashboard/tender-drafts/" + str(${localID})
    Wait Until Page Contains Element    xpath=//a[@href="${hrefToTender}"]    30
    Go to  ${NewTenderUrl}
	Wait Until Page Contains Element  id=tenderUID    15
	Wait Until Page Contains Element  id=tenderID     15
    ${tender_id}=  Get Text  xpath=//a[@id='tenderUID']
    ${TENDER_UA}=  Get Text  id=tenderID
    set global variable  ${TENDER_UA}
    ${ViewTenderUrl}=  assemble_viewtender_url  ${NewTenderUrl}  ${tender_id}
    log to console  *************
    log to console  ViewTenderUrl ${ViewTenderUrl}
	SET GLOBAL VARIABLE  ${ViewTenderUrl}
    log to console  закінчили "Створити тендер complaints"

Отримуємо код ДК
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  tender_data
  ${items}=                             Get From Dictionary             ${ARGUMENTS[0].data}                        items
  ${add_scheme}=                        Get From Dictionary             ${items[0].additionalClassifications[0]}    scheme
  ${add_id}=                            Get From Dictionary             ${items[0].additionalClassifications[0]}    id
  ${add_descr}=                         Get From Dictionary             ${items[0].additionalClassifications[0]}    description
  set global variable  ${add_scheme}
  set global variable  ${add_id}
  set global variable  ${add_descr}
  log to console  *
  log to console  Додатковий код
  log to console  ${add_scheme}
  log to console  ${add_id}
  log to console  ${add_descr}
  log to console  *

Заповнюємо додаткові коди
    Execute Javascript    angular.element("#cpv").scope().value.additionalClassifications = [{id: "${add_id}", description: "${add_descr}", scheme: "${add_scheme}"}];
    sleep  2

Створити тендер negotiation
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...      ${ARGUMENTS[0]} ==  username
    ...      ${ARGUMENTS[1]} ==  tender_data
    log to console  *
    log to console  починаємо "Створити тендер negotiation"

    ${title}=                             Get From Dictionary             ${ARGUMENTS[1].data}                   title
    ${description}=                       Get From Dictionary             ${ARGUMENTS[1].data}                   description
    ${cause}=                             Get From Dictionary             ${ARGUMENTS[1].data}                   cause
    ${causedescription}=                  Get From Dictionary             ${ARGUMENTS[1].data}                   causeDescription
    ${items}=                             Get From Dictionary             ${ARGUMENTS[1].data}                   items
    ${vat}=                               get from dictionary             ${ARGUMENTS[1].data.value}             valueAddedTaxIncluded
    ${lots}=                              Get From Dictionary             ${ARGUMENTS[1].data}                   lots
    ${lot1_description}=                  Get From Dictionary             ${lots[0]}                             description
    ${lot1_title}=                        Get From Dictionary             ${lots[0]}                             title
    ${lot1_tax}=                          Get From Dictionary             ${lots[0].value}                       valueAddedTaxIncluded
    ${lot1_amount_str}=                   convert to string               ${ARGUMENTS[1].data.lots[0].value.amount}
    ${item1_description}=                 Get From Dictionary             ${items[0]}                            description
    ${item1_cls_description}=             Get From Dictionary             ${items[0].classification}             description
    ${item1_cls_id}=                      Get From Dictionary             ${items[0].classification}             id
    ${item1_cls_scheme}=                  Get From Dictionary             ${items[0].classification}             scheme
    run keyword and ignore error          Отримати коди додаткової класифікації                                  ${ARGUMENTS[1]}
    ${item1_quantity}=                    Get From Dictionary             ${items[0]}                            quantity
    ${item1_package}=                     Get From Dictionary             ${items[0].unit}                       name
    ${item1_streetAddress}=               Get From Dictionary             ${items[0].deliveryAddress}            streetAddress
    ${item1_locality}=                    Get From Dictionary             ${items[0].deliveryAddress}            locality
    ${item1_region}=                      Get From Dictionary             ${items[0].deliveryAddress}            region
    ${item1_postalCode}=                  Get From Dictionary             ${items[0].deliveryAddress}            postalCode
    ${item1_countryName}=                 Get From Dictionary             ${items[0].deliveryAddress}            countryName
    ${item1_delivery_startDate}=          Get From Dictionary             ${items[0].deliveryDate}               startDate
    ${item1_delivery_endDate}=            Get From Dictionary             ${items[0].deliveryDate}               endDate
    ${item1_delivery_StartDate_str}=      convert_datetime_to_new         ${item1_delivery_startDate}
	${item1_delivery_StartDate_time}=     convert_datetime_to_new_time    ${item1_delivery_startDate}
	${item1_delivery_endDate_str}=        convert_datetime_to_new         ${item1_delivery_endDate}
	${item1_delivery_endDate_time}=       convert_datetime_to_new_time    ${item1_delivery_endDate}
	${item2_description}=                 Get From Dictionary             ${items[1]}                            description
	${item2_quantity}=                    Get From Dictionary             ${items[1]}                            quantity
	${item2_cls_description}=             Get From Dictionary             ${items[1].classification}             description
    ${item2_cls_id}=                      Get From Dictionary             ${items[1].classification}             id
    ${item2_cls_scheme}=                  Get From Dictionary             ${items[1].classification}             scheme
    ${item2_package}=                     Get From Dictionary             ${items[1].unit}                       name
    ${item2_streetAddress}=               Get From Dictionary             ${items[1].deliveryAddress}            streetAddress
    ${item2_locality}=                    Get From Dictionary             ${items[1].deliveryAddress}            locality
    ${item2_region}=                      Get From Dictionary             ${items[1].deliveryAddress}            region
    ${item2_postalCode}=                  Get From Dictionary             ${items[1].deliveryAddress}            postalCode
    ${item2_countryName}=                 Get From Dictionary             ${items[1].deliveryAddress}            countryName
    ${item2_delivery_startDate}=          Get From Dictionary             ${items[1].deliveryDate}               startDate
    ${item2_delivery_endDate}=            Get From Dictionary             ${items[1].deliveryDate}               endDate
    ${item2_delivery_StartDate_str}=      convert_datetime_to_new         ${item2_delivery_startDate}
	${item2_delivery_StartDate_time}=     convert_datetime_to_new_time    ${item2_delivery_startDate}
	${item2_delivery_endDate_str}=        convert_datetime_to_new         ${item2_delivery_endDate}
	${item2_delivery_endDate_time}=       convert_datetime_to_new_time    ${item2_delivery_endDate}
	${contact_point_name}=                Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    name
	${contact_point_phone}=               Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    telephone
	${contact_point_fax}=                 Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    faxNumber
	${contact_point_email}=               Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    email
    ${acceleration_mode}=                 Get From Dictionary             ${ARGUMENTS[1].data}                                 procurementMethodDetails

    #клікаєм на "Мій кабінет"
    click element  xpath=/html/body/app-shell/md-toolbar[1]/app-header/div[1]/div[3]/div[1]/div[2]/app-main-menu/md-nav-bar/div/nav/ul/li[3]/a/span/span[2]
    sleep  2
    wait until element is visible  ${Кнопка "Мої закупівлі"}  30
    click element  ${Кнопка "Мої закупівлі"}
    sleep  2
    wait until element is visible  ${Кнопка "Створити"}  30
    click element  ${Кнопка "Створити"}
    sleep  1
    wait until element is visible  ${Поле "Узагальнена назва закупівлі"}  30
    input text  ${Поле "Узагальнена назва закупівлі"}  ${title}
    run keyword if       '${vat}'     click element      id=tender-value-vat
    click element  ${Поле "Процедура закупівлі"}
    sleep  1
    wait until element is visible  ${Поле "Процедура закупівлі" варіант "Переговорна процедура"}  30
    click element  ${Поле "Процедура закупівлі" варіант "Переговорна процедура"}
    sleep  1
    #заповнюємо поле "Підстава для використання"
    Execute Javascript    $("form[ng-submit='onSubmit($event)']").scope().tender.causeUsing = '${cause}'
    sleep  1
    input text  id=causeDescription  ${causedescription}
    input text  id=description  ${description}
    #Переходимо на вкладку "Лоти закупівлі"
    click element  ${Вкладка "Лоти закупівлі"}
    wait until element is visible  ${Поле "Узагальнена назва лоту"}  30
    input text      ${Поле "Узагальнена назва лоту"}                    ${lot1_title}
    #заповнюємо поле "Очікувана вартість закупівлі"
    input text      amount-lot-value.0                                  ${lot1_amount_str}
    sleep  1
    #Заповнюємо поле "Примітки"
    input text      lotDescription-0                                    ${lot1_description}
    #переходимо на вкладку "Специфікації закупівлі"
    Execute Javascript  $($("app-tender-lot")).find("md-tab-item")[1].click()
    wait until element is visible  ${Поле "Конкретна назва предмета закупівлі"}  30
    input text      ${Поле "Конкретна назва предмета закупівлі"}        ${item1_description}
    input text      id=itemQuantity--                                   ${item1_quantity}
    #Заповнюємо поле "Код ДК 021-2015 "
    Execute Javascript    $($('[id=cpv]')[0]).scope().value.classification = {id: "${item1_cls_id}", description: "${item1_cls_description}", scheme: "${item1_cls_scheme}"};
    sleep  2
    #Заповнюємо поле "Додаткові коди"
    run keyword and ignore error  Заповнити додаткові коди першого айтему
    #Заповнюємо поле "Одиниці виміру"
    Select From List  id=unit-unit--  ${item1_package}
    input text  xpath=(.//app-lot-specification//app-datetime-picker)[1]//input[@class='md-datepicker-input']  ${item1_delivery_StartDate_str}
    sleep  2
    Input text    xpath=(//*[@id="timeInput"])[1]                                                              ${item1_delivery_StartDate_time}
    sleep  2
    input text  xpath=(.//app-lot-specification//app-datetime-picker)[2]//input[@class='md-datepicker-input']  ${item1_delivery_endDate_str}
    sleep  2
    input text  xpath=(//*[@id="timeInput"])[2]                                                                ${item1_delivery_EndDate_time}
    select from list  id=countryName.value.deliveryAddress--                                                   ${item1_countryName}
    input text  id=streetAddress.value.deliveryAddress--                                                       ${item1_streetAddress}
    input text  id=locality.value.deliveryAddress--                                                            ${item1_locality}
    input text  id=region.value.deliveryAddress--                                                              ${item1_region}
    input text  id=postalCode.value.deliveryAddress--                                                          ${item1_postalCode}
    sleep  3
    # Переходимо на вкладку "Контактна особа"
    Execute Javascript    angular.element("md-tab-item")[3].click()
    sleep  3
    Execute Javascript    angular.element("md-tab-item")[1].click()
    wait until element is visible  id=itemAddAction     60
    #Натискаємо на кнопку "ДОДАТИ"
    click element  id=itemAddAction
    wait until element is visible  xpath=(//*[@id='itemDescription--'])[2]  30
    input text            xpath=(//*[@id='itemDescription--'])[2]                                                            ${item2_description}
    input text            xpath=(//*[@id='itemQuantity--'])[2]                                                               ${item2_quantity}
    #Заповнюємо поле "Код ДК 021-2015 "
    Execute Javascript    $($('[id=cpv]')[1]).scope().value.classification = {id: "${item2_cls_id}", description: "${item2_cls_description}", scheme: "${item2_cls_scheme}"};
    sleep  2
    #Заповнюємо поле "Додаткові коди"
    RUN KEYWORD AND IGNORE ERROR  Заповнити додаткові коди другого айтему
    #Заповнюємо поле "Одиниці виміру"
    Select From List      xpath=(//*[@id='unit-unit--'])[2]                                                                  ${item2_package}
    input text            xpath=(.//app-lot-specification//app-datetime-picker)[3]//input[@class='md-datepicker-input']      ${item2_delivery_StartDate_str}
    sleep  2
    Input text            xpath=(//*[@id="timeInput"])[3]                                                                    ${item2_delivery_StartDate_time}
    sleep  2
    input text            xpath=(.//app-lot-specification//app-datetime-picker)[4]//input[@class='md-datepicker-input']      ${item2_delivery_endDate_str}
    sleep  2
    input text            xpath=(//*[@id="timeInput"])[4]                                                                    ${item2_delivery_EndDate_time}
    select from list      xpath=(//*[@id='countryName.value.deliveryAddress--'])[2]                                          ${item2_countryName}
    input text            xpath=(//*[@id='streetAddress.value.deliveryAddress--'])[2]                                        ${item2_streetAddress}
    input text            xpath=(//*[@id='locality.value.deliveryAddress--'])[2]                                             ${item2_locality}
    input text            xpath=(//*[@id='region.value.deliveryAddress--'])[2]                                               ${item2_region}
    input text            xpath=(//*[@id='postalCode.value.deliveryAddress--'])[2]                                           ${item2_postalCode}
    sleep  3
    # Переходимо на вкладку "Контактна особа"
    Execute Javascript    angular.element("md-tab-item")[3].click()
    sleep  3
    input text            procuringEntityContactPointName                          ${contact_point_name}
    input text            procuringEntityContactPointEmail                         ${contact_point_email}
    input text            procuringEntityContactPointTelephone                     ${contact_point_phone}
    input text            procuringEntityContactPointFax                           ${contact_point_fax}
    input text            procurementMethodDetails                                 quick, accelerator=1440
    input text            mode                                                     test
    sleep  3
    click button          id=tender-apply
    sleep  10
    ${NewTenderUrl}=  Execute Javascript  return window.location.href
    SET GLOBAL VARIABLE  ${NewTenderUrl}
    sleep  4
    wait until element is visible  ${Поле "Узагальнена назва закупівлі"}  100
    click button  ${Кнопка "Опублікувати"}
    wait until element is visible  ${Кнопка "Так" у попап вікні}  100
    click element  ${Кнопка "Так" у попап вікні}
    wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
    ${localID}=    get_local_id_from_url        ${NewTenderUrl}
    ${hrefToTender}=    Evaluate    "/dashboard/tender-drafts/" + str(${localID})
    Wait Until Page Contains Element    xpath=//a[@href="${hrefToTender}"]    100
    Go to  ${NewTenderUrl}
	Wait Until Page Contains Element  id=tenderUID    100
	Wait Until Page Contains Element  id=tenderID     100
    ${tender_id}=  Get Text  xpath=//a[@id='tenderUID']
    ${TENDER_UA}=  Get Text  id=tenderID
    set global variable  ${TENDER_UA}
    ${ViewTenderUrl}=  assemble_viewtender_url  ${NewTenderUrl}  ${tender_id}
    log to console  *
    log to console  ViewTenderUrl ${ViewTenderUrl}
    log to console  *
	SET GLOBAL VARIABLE  ${ViewTenderUrl}
    log to console  закінчили "Створити тендер negotiation"


Отримати коди додаткової класифікації
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  tender_data
  ${items}=                             Get From Dictionary             ${ARGUMENTS[0].data}                      items
  ${item1_add_description}=             Get From Dictionary             ${items[0].additionalClassifications[0]}  description
  ${item1_add_id}=                      Get From Dictionary             ${items[0].additionalClassifications[0]}  id
  ${item1_add_scheme}=                  Get From Dictionary             ${items[0].additionalClassifications[0]}  scheme
  ${item2_add_description}=             Get From Dictionary             ${items[1].additionalClassifications[0]}  description
  ${item2_add_id}=                      Get From Dictionary             ${items[1].additionalClassifications[0]}  id
  ${item2_add_scheme}=                  Get From Dictionary             ${items[1].additionalClassifications[0]}  scheme
  set global variable  ${item1_add_description}
  set global variable  ${item1_add_id}
  set global variable  ${item1_add_scheme}
  set global variable  ${item2_add_description}
  set global variable  ${item2_add_id}
  set global variable  ${item2_add_scheme}

Заповнити додаткові коди першого айтему
    Execute Javascript    angular.element("[key='cpv-0-0']").scope().value.additionalClassifications = [{id: "${item1_add_id}", description: "${item1_add_description}", scheme: "${item1_add_scheme}"}];
    sleep  2

Заповнити додаткові коди другого айтему
    Execute Javascript    angular.element("[key='cpv-0-1']").scope().value.additionalClassifications = [{id: "${item2_add_id}", description: "${item2_add_description}", scheme: "${item2_add_scheme}"}];
    sleep  2

Завантажити документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${TENDER}
  #Натискаємо на поле "Документи закупівлі"
  click element  xpath=/html/body/app-shell/md-content/app-content/div/div[2]/div[2]/div/div/div/md-content/div/form/div/div/md-content/ng-transclude/md-tabs/md-tabs-wrapper/md-tabs-canvas/md-pagination-wrapper/md-tab-item[3]
  #Натискаємо кнопку "Додати"
  click button  tenderDocumentAddAction
  #Обираємо тип документу
  select from list  type-tender-documents-0  Тендерна документація
  sleep  1
  input text  description-tender-documents-0  Назва документа
  choose file  id=file-tender-documents-0  ${ARGUMENTS[1]}
  click button  ${Кнопка "Опублікувати"}
  wait until element is visible  ${Кнопка "Так" у попап вікні}  60
  click element  ${Кнопка "Так" у попап вікні}
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120

Створити постачальника, додати документацію і підтвердити його
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_owner}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  supplier_data
  ...      ${ARGUMENTS[3]} ==  ${file_path}
  ${adapted_suplier_data}=            accept_service.adapt_supplier_data    ${ARGUMENTS[2]}
  ${suppliers}=                       Get From Dictionary                   ${adapted_suplier_data.data}         suppliers
  ${suppliers_countryName}=           Get From Dictionary                   ${suppliers[0].address}              countryName
  ${suppliers_locality}=              Get From Dictionary                   ${suppliers[0].address}              locality
  ${suppliers_postalCode}=            Get From Dictionary                   ${suppliers[0].address}              postalCode
  ${suppliers_region}=                Get From Dictionary                   ${suppliers[0].address}              region
  ${suppliers_streetAddress}=         Get From Dictionary                   ${suppliers[0].address}              streetAddress
  ${suppliers_email}=                 Get From Dictionary                   ${suppliers[0].contactPoint}         email
  ${suppliers_faxNumber}=             Get From Dictionary                   ${suppliers[0].contactPoint}         faxNumber
  ${suppliers_cpname}=                Get From Dictionary                   ${suppliers[0].contactPoint}         name
  ${suppliers_telephone}=             Get From Dictionary                   ${suppliers[0].contactPoint}         telephone
  ${suppliers_url}=                   Get From Dictionary                   ${suppliers[0].contactPoint}         url
  ${suppliers_legalName}=             Get From Dictionary                   ${suppliers[0].identifier}           legalName
  ${suppliers_id}=                    Get From Dictionary                   ${suppliers[0].identifier}           id
  ${suppliers_name}=                  Get From Dictionary                   ${suppliers[0]}                      name
  ${suppliers_amount}=                Get From Dictionary                   ${adapted_suplier_data.data.value}   amount
  ${suppliers_currency}=              Get From Dictionary                   ${adapted_suplier_data.data.value}   currency
  ${suppliers_tax}=                   Get From Dictionary                   ${adapted_suplier_data.data.value}   valueAddedTaxIncluded
  Go to  ${NewTenderUrl}
  wait until element is visible  ${Посилання на тендер}  20
  click element  ${Посилання на тендер}
  wait until element is visible  ${Кнопка "Зберегти учасника переговорів"}  20
  click button  ${Кнопка "Зберегти учасника переговорів"}
  wait until element is visible  ${Поле "Ціна пропозиції"}  20
  input text            ${Поле "Ціна пропозиції"}           ${suppliers_amount}
  select from list      id                                  ${suppliers_currency}
  input text            supplier-name-0                     ${suppliers_legalName}
  input text            supplier-cp-name-0                  ${suppliers_cpname}
  input text            supplier-cp-email-0                 ${suppliers_email}
  input text            supplier-cp-telephone-0             ${suppliers_telephone}
  input text            supplier-identifier-id-0            ${suppliers_id}
  input text            supplier-identifier-legalName-0     ${suppliers_legalName}
  input text            supplier-address-locality-0         ${suppliers_locality}
  input text            supplier-address-streetAddress-0    ${suppliers_streetAddress}
  input text            supplier-address-postalCode-0       ${suppliers_postalCode}
  select from list      supplier-address-country-0          ${suppliers_countryName}
  select from list      supplier-address-region-0           ${suppliers_region}
  sleep  1
  click element  xpath=/html/body/div[1]/div/div/form/ng-transclude/div[3]/button[1]
  wait until element is visible  xpath=//div[contains(text(),'публіковано')]  300
  click element  id=award-negot-active-0
  wait until element is visible  xpath=.//button[@ng-click='onDocumentAdd()']  30
  #Додаємо файл
  click button                   xpath=.//button[@ng-click='onDocumentAdd()']
  wait until element is visible  ${Поле "Тип документа" (Кваліфікація учасників)}
  select from list  ${Поле "Тип документа" (Кваліфікація учасників)}  Повідомлення
  sleep  1
  input text  description-award-document  Назва документу
  choose file  id=file-award-document  ${ARGUMENTS[3]}
  sleep  2
  click element  award-qualified
  sleep  2
  click element  xpath=/html/body/div[1]/div/div/form/ng-transclude/div[3]/button[1]
  wait until element is visible  xpath=//div[contains(text(),'публіковано')]  300

Оновити сторінку з тендером
    [Arguments]    @{ARGUMENTS}
    [Documentation]
    ...      ${ARGUMENTS[0]} = username
    ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
	Switch Browser    ${ARGUMENTS[0]}
	Run Keyword If   '${ARGUMENTS[0]}' == 'accept_Owner'   Go to    ${NewTenderUrl}

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER}
  #натискаємо кнопку пошук (для сценарію complaints)
  run keyword if  '${TENDER_TYPE}' == 'complaints'  click element  xpath=(.//span[@class='ng-binding ng-scope'])[2]
  sleep  5
  # Кнопка  "Розширений пошук"
  Click Button    xpath=//tender-search-panel//div[@class='advanced-search-control']//button[contains(@ng-click, 'advancedSearchHidden')]
  sleep  2
  Input Text      id=identifier    ${ARGUMENTS[1]}
  Click Button    id=searchButton
  Sleep  10
  click element   xpath=(.//div[@class='resultItemHeader'])[1]/a
  sleep  10
  ${ViewTenderUrl}=    Execute Javascript    return window.location.href
  SET GLOBAL VARIABLE    ${ViewTenderUrl}
  sleep  1

Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  field
  go to  ${ViewTenderUrl}
  sleep  5
  run keyword if  '${TENDER_TYPE}' == 'complaints'   Отримати інформацію із тендера для скарг                    @{ARGUMENTS}
  run keyword if  '${TENDER_TYPE}' == 'negotiation'  Отримати інформацію із тендера для переговорної процедури  @{ARGUMENTS}
  [return]  ${return_value}

Отримати інформацію із тендера для переговорної процедури
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${field}
  ${return_value}=  run keyword  Отримати інформацію про ${ARGUMENTS[2]}
  set global variable  ${return_value}

Отримати інформацію із тендера для скарг
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${field}

  go to  ${ViewTenderUrl}
  wait until element is visible            xpath=.//span[@ng-if='data.status']  60
  ${return_value}=  get element attribute  xpath=//*[@id="robotStatus"]@textContent
  log to console  *
  log to console  статус тендера= ${return_value}
  log to console  *
  set global variable  ${return_value}

###############################

Отримати інформацію про title
#Відображення заголовку переговорної процедури
  sleep  10
  ${return_value}=    Execute Javascript            return angular.element("#robotStatus").scope().data.title
  ${count}=           get matching xpath count      .//span[@dataanchor='scheme']
  set global variable  ${count}
  run keyword if  ${count}== 4  999 CPV Counter
  [return]  ${return_value}

999 CPV Counter
  ${count}=  convert to integer    3
  set global variable  ${count}

Отримати інформацію про tenderId
#Відображення ідентифікатора переговорної процедури
    wait until element is visible  id=tenderID  20
    ${return_value}=    Get Text   id=tenderID
    [return]    ${return_value}

Отримати інформацію про description
#Відображення опису переговорної процедури
    wait until element is visible  xpath=.//*[@dataanchor='tenderView']//*[@dataanchor='description']  20
	${return_value}=    Get Text   xpath=.//*[@dataanchor='tenderView']//*[@dataanchor='description']
    [return]  ${return_value}

Отримати інформацію про causeDescription
#Відображення підстави вибору переговорної процедури
    wait until element is visible  id=causeDescription  20
	${return_value}=    Get Text   id=causeDescription
    [return]  ${return_value}

Отримати інформацію про cause
#Відображення обгрунтування причини вибору переговорної процедури
    wait until element is visible  id=cause  20
	${return_value}=    get value  id=cause
    [return]  ${return_value}

Отримати інформацію про value.amount
#Відображення бюджету переговорної процедури
    wait until element is visible  xpath=(.//*[@dataanchor='value'])[1]  20
	${return_value}=     Get Text  xpath=(.//*[@dataanchor='value'])[1]
	${return_value}=    get_numberic_part    ${return_value}
	${return_value}=    Convert To Number    ${return_value}
    [return]  ${return_value}

Отримати інформацію про value.currency
#Відображення валюти переговорної процедури
    wait until element is visible  xpath=.//*[@dataanchor='value.currency']  20
	${return_value}=     Get Text  xpath=.//*[@dataanchor='value.currency']
    [return]  ${return_value}

Отримати інформацію про value.valueAddedTaxIncluded
#Відображення врахованого податку в бюджет переговорної процедури
    wait until element is visible  xpath=.//*[@dataanchor='tenderView']//*[@dataanchor='value.valueAddedTaxIncluded']  20
    ${tax}=              Get Text  xpath=.//*[@dataanchor='tenderView']//*[@dataanchor='value.valueAddedTaxIncluded']
    ${return_value}=    tax adapt  ${tax}
    [return]  ${return_value}

Отримати інформацію про procuringEntity.address.countryName
#Відображення країни замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='sub-text-block']/div)[2]
    ${temp_value} =      get text  xpath=(.//div[@class='sub-text-block']/div)[2]
    ${value}=  convert to integer  1
    ${return_value}=  parse_address_for_viewer  ${temp_value}  ${value}
    [return]  ${return_value}

Отримати інформацію про procuringEntity.address.locality
#Відображення населеного пункту замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='sub-text-block']/div)[2]  20
    ${temp_value} =      get text  xpath=(.//div[@class='sub-text-block']/div)[2]
    ${value}=  convert to integer  3
    ${return_value}=  parse_address_for_viewer  ${temp_value}  ${value}
    [return]  ${return_value}

Отримати інформацію про procuringEntity.address.postalCode
#Відображення поштового коду замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='sub-text-block']/div)[2]  20
    ${temp_value} =      get text  xpath=(.//div[@class='sub-text-block']/div)[2]
    ${value}=  convert to integer  0
    ${return_value}=  parse_address_for_viewer  ${temp_value}  ${value}
    [return]  ${return_value}

Отримати інформацію про procuringEntity.address.region
#Відображення області замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='sub-text-block']/div)[2]  20
    ${temp_value} =      get text  xpath=(.//div[@class='sub-text-block']/div)[2]
    ${value}=  convert to integer  2
    ${return_value}=  parse_address_for_viewer  ${temp_value}  ${value}
    [return]  ${return_value}

Отримати інформацію про procuringEntity.address.streetAddress
#Відображення вулиці замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='sub-text-block']/div)[2]  20
    ${temp_value} =      get text  xpath=(.//div[@class='sub-text-block']/div)[2]
    ${value}=  convert to integer  4
    ${return_value}=  parse_address_for_viewer  ${temp_value}  ${value}
    [return]  ${return_value}

Отримати інформацію про procuringEntity.contactPoint.name
#Відображення контактного імені замовника переговорної процедури
    wait until element is visible  xpath=.//div[@class='field-value ng-binding flex']  20
	${return_value}=     Get Text  xpath=.//div[@class='field-value ng-binding flex']
    [return]  ${return_value}

Отримати інформацію про procuringEntity.contactPoint.telephone
#Відображення контактного телефону замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='field-value flex'])[1]  20
	${return_value}=     Get Text  xpath=(.//div[@class='field-value flex'])[1]
    [return]  ${return_value}

Отримати інформацію про procuringEntity.contactPoint.url
#Відображення сайту замовника переговорної процедури
    wait until element is visible  xpath=.//div[@class='horisontal-centering']  20
	${return_value}=     Get Text  xpath=.//div[@class='horisontal-centering']
    [return]  ${return_value}

Отримати інформацію про procuringEntity.identifier.legalName
#Відображення офіційного імені замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='sub-text-block'])[1]  20
	${return_value}=     Get Text  xpath=(.//div[@class='sub-text-block'])[1]
    [return]  ${return_value}

Отримати інформацію про procuringEntity.identifier.id
#Відображення ідентифікатора замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='horisontal-centering ng-binding'])[2]  20
	${return_value}=     Get Text  xpath=(.//div[@class='horisontal-centering ng-binding'])[2]
    [return]  ${return_value}

Отримати інформацію про procuringEntity.name
#Відображення імені замовника переговорної процедури
    wait until element is visible  xpath=.//div[@class='align-text-at-center flex-none']  20
	${return_value}=     Get Text  xpath=.//div[@class='align-text-at-center flex-none']
    [return]  ${return_value}

Отримати інформацію про documents[0].title
    wait until element is visible  xpath=(.//button[@tender-id])[1]  20
    click element                  xpath=(.//button[@tender-id])[1]
    sleep  3
	${return_value}=  Get Text     xpath=.//div[@class='document-title-label']
    [return]  ${return_value}

Отримати інформацію про awards[0].documents[0].title
    wait until element is visible  xpath=(.//button[@tender-id])[2]  20
    click element                  xpath=(.//button[@tender-id])[2]
    sleep  3
	${return_value}=  Get Text     xpath=.//div[@class='document-title-label']
    [return]  ${return_value}

Отримати інформацію про awards[0].status
    wait until element is visible  xpath=(.//td[@class='ng-binding'])[3]  20
	${return_value}=  Get Text     xpath=(.//td[@class='ng-binding'])[3]
    ${return_value}=  participant status  ${return_value}
    [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].address.countryName
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[3]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[3]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].address.locality
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[4]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[4]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].address.postalCode
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[5]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[5]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].address.region
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[6]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[6]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].address.streetAddress
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[7]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[7]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про procuringEntity.identifier.scheme
#Відображення схеми ідентифікації замовника переговорної процедури
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=.//div[@id='OwnerScheme']  20
    ${return_value}=  get element attribute  xpath=.//div[@id='OwnerScheme']@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].contactPoint.telephone
    click element  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//a[@rel='nofollow'])[5]  20
    ${return_value}=  get element attribute  xpath=(.//a[@rel='nofollow'])[5]@textContent
    [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].contactPoint.name
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[2]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[2]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].contactPoint.email
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//a[@rel='nofollow'])[7]  20
    ${return_value}=  get element attribute  xpath=(.//a[@rel='nofollow'])[7]@textContent
    [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].identifier.scheme
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[8]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[8]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].identifier.legalName
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[9]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[9]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].identifier.id
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex-20'])  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex-20'])@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].name
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=.//div[@class='horisontal-centering ng-binding flex']  20
    ${return_value}=  get element attribute  xpath=.//div[@class='horisontal-centering ng-binding flex']@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про awards[0].value.valueAddedTaxIncluded
    wait until element is visible  xpath=(.//span[@dataanchor='value.valueAddedTaxIncluded'])[2]  20
    ${value}=  get text            xpath=(.//span[@dataanchor='value.valueAddedTaxIncluded'])[2]
    ${return_value}=  tax_adapt  ${value}
    [return]  ${return_value}

Отримати інформацію про awards[0].value.currency
    wait until element is visible  xpath=(.//span[@dataanchor='value.currency'])[2]  20
    ${return_value}=     get text  xpath=(.//span[@dataanchor='value.currency'])[2]
    [return]  ${return_value}

Отримати інформацію про awards[0].value.amount
    wait until element is visible  xpath=.//span[@dataanchor='value.amount']  20
    ${value}=            get text  xpath=.//span[@dataanchor='value.amount']
    ${return_value}=  convert to integer  ${value}
    [return]  ${return_value}

Отримати інформацію про contracts[0].status
    wait until element is visible  xpath=.//span[@id='contract-status']  20
	${return_value}=  get value  xpath=.//span[@id='contract-status']
    [return]  ${return_value}

Отримати інформацію із предмету
    [Arguments]  ${username}  ${tender_uaid}  ${object_id}  ${field_name}
    go to  ${ViewTenderUrl}
    sleep  10
    click element  xpath=(//span[starts-with(@class,'glyphicon')])[11]
    sleep  1
    click element  xpath=(//span[starts-with(@class,'glyphicon')])[12]
    sleep  1
    run keyword if  '${field_name}' == 'description'                                Отримати інформацію про items[0].description
    run keyword if  '${field_name}' == 'additionalClassifications[0].description'   Отримати інформацію про items[0].additionalClassifications[0].description
    run keyword if  '${field_name}' == 'additionalClassifications[0].id'            Отримати інформацію про items[0].additionalClassifications[0].id
    run keyword if  '${field_name}' == 'additionalClassifications[0].scheme'        Отримати інформацію про items[0].additionalClassifications[0].scheme
    run keyword if  '${field_name}' == 'classification.scheme'                      Отримати інформацію про items[0].classification.scheme
    run keyword if  '${field_name}' == 'classification.id'                          Отримати інформацію про items[0].classification.id
    run keyword if  '${field_name}' == 'classification.description'                 Отримати інформацію про items[0].classification.description
    run keyword if  '${field_name}' == 'quantity'                                   Отримати інформацію про items[0].quantity
    run keyword if  '${field_name}' == 'unit.name'                                  Отримати інформацію про items[0].unit.name
    run keyword if  '${field_name}' == 'unit.code'                                  Отримати інформацію про items[0].unit.code
    run keyword if  '${field_name}' == 'deliveryDate.endDate'                       Отримати інформацію про items[0].deliveryDate.endDate
    run keyword if  '${field_name}' == 'deliveryAddress.countryName'                Отримати інформацію про items[0].deliveryAddress.countryName
    run keyword if  '${field_name}' == 'deliveryAddress.postalCode'                 Отримати інформацію про items[0].deliveryAddress.postalCode
    run keyword if  '${field_name}' == 'deliveryAddress.region'                     Отримати інформацію про items[0].deliveryAddress.region
    run keyword if  '${field_name}' == 'deliveryAddress.locality'                   Отримати інформацію про items[0].deliveryAddress.locality
    run keyword if  '${field_name}' == 'deliveryAddress.streetAddress'              Отримати інформацію про items[0].deliveryAddress.streetAddress
    [return]  ${return_value}

Отримати інформацію про items[0].description
#Відображення опису номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@convert-line-break])[1]@textContent
    [return]  ${return_value}

Отримати інформацію про items[1].description
#Відображення опису номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@convert-line-break])[2]@textContent
    [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].description
#Відображення опису основної/додаткової класифікації номенклатур пе
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='description'])[2]@textContent
    [return]  ${return_value}

Отримати інформацію про items[1].additionalClassifications[0].description
#Відображення опису основної/додаткової класифікації номенклатур пе
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='description'])[4]@textContent
    [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].id
#Відображення ідентифікатора основної/додаткової класифікації номен
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='value'])[2]@textContent
    [return]  ${return_value}

Отримати інформацію про items[1].additionalClassifications[0].id
#Відображення ідентифікатора основної/додаткової класифікації номен
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='value'])[4]@textContent
    [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].scheme
#Відображення схеми основної/додаткової класифікації номенклатур пе
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='scheme'])[2]@textContent
    [return]  ${return_value}

Отримати інформацію про items[1].additionalClassifications[0].scheme
#Відображення схеми основної/додаткової класифікації номенклатур пе
    sleep  5
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='scheme'])[4]@textContent
    [return]  ${return_value}

Отримати інформацію про items[0].classification.scheme
    sleep  5
#Відображення схеми основної/додаткової класифікації номенклатур пе
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='scheme'])[1]@textContent
    [return]  ${return_value}

Отримати інформацію про items[1].classification.scheme
#Відображення схеми основної/додаткової класифікації номенклатур пе
    sleep  10
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='scheme'])[${count}]@textContent
    [return]  ${return_value}

Отримати інформацію про items[0].classification.id
#Відображення ідентифікатора основної/додаткової класифікації номен
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='value'])[1]@textContent
    [return]  ${return_value}

Отримати інформацію про items[1].classification.id
#Відображення ідентифікатора основної/додаткової класифікації номен
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='value'])[${count}]@textContent
    [return]  ${return_value}

Отримати інформацію про items[0].classification.description
#ідображення опису основної/додаткової класифікації номенклатур пе
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='description'])[1]@textContent
    [return]  ${return_value}

Отримати інформацію про items[1].classification.description
#ідображення опису основної/додаткової класифікації номенклатур пе
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='description'])[${count}]@textContent
    [return]  ${return_value}

Отримати інформацію про items[0].quantity
#Відображення кількості номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity'])[1]@textContent
    ${return_value}=  convert to integer  ${return_value}
    [return]  ${return_value}

Отримати інформацію про items[1].quantity
#Відображення кількості номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity'])[2]@textContent
    ${return_value}=  convert to integer  ${return_value}
    [return]  ${return_value}

Отримати інформацію про items[0].unit.name
#Відображення назви одиниці номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity.unit.name'])[1]@textContent
    [return]  ${return_value}

Отримати інформацію про items[1].unit.name
#Відображення назви одиниці номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity.unit.name'])[1]@textContent
    [return]  ${return_value}

Отримати інформацію про items[0].unit.code
#ідображення коду одиниці номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity.unit.code'])[1]@textContent
    [return]  ${return_value}

Отримати інформацію про items[1].unit.code
#ідображення коду одиниці номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity.unit.code'])[2]@textContent
    [return]  ${return_value}

Отримати інформацію про items[0].deliveryDate.endDate
#Відображення дати доставки номенклатури переговорної процедури
    ${return_value}=  get value  xpath=(.//span[@dataanchor='deliveryDate.endDate'])[1]
    [return]  ${return_value}

Отримати інформацію про items[1].deliveryDate.endDate
#Відображення дати доставки номенклатури переговорної процедури
    ${return_value}=  get value  xpath=(.//span[@dataanchor='deliveryDate.endDate'])[2]
    [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName
#Відображення назви країни доставки номенклатури переговорної проце
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='countryName'])[1]@textContent
    [return]  ${return_value}

Отримати інформацію про items[1].deliveryAddress.countryName
#Відображення назви країни доставки номенклатури переговорної проце
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='countryName'])[2]@textContent
    [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.postalCode
#Відображення пошт. коду доставки номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='postalCode'])[1]@textContent
    [return]  ${return_value}

Отримати інформацію про items[1].deliveryAddress.postalCode
#Відображення пошт. коду доставки номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='postalCode'])[2]@textContent
    [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.region
#Відображення регіону доставки номенклатури переговорної процедури
    sleep  5
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='region'])[1]@textContent
    [return]  ${return_value}

Отримати інформацію про items[1].deliveryAddress.region
#Відображення регіону доставки номенклатури переговорної процедури
    sleep  5
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='region'])[2]@textContent
    [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.locality
#Відображення населеного пункту адреси доставки номенклатури перего
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='locality'])[1]@textContent
    [return]  ${return_value}

Отримати інформацію про items[1].deliveryAddress.locality
#Відображення населеного пункту адреси доставки номенклатури перего
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='locality'])[2]@textContent
    [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.streetAddress
#Відображення вулиці доставки номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='streetAddress'])[1]@textContent
    [return]  ${return_value}

Отримати інформацію про items[1].deliveryAddress.streetAddress
#Відображення вулиці доставки номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='streetAddress'])[2]@textContent
    [return]  ${return_value}

################################################################################################################
#            Кейворди які не можуть бути реалізовані через відсутність відповідних полів на майданчику         #
################################################################################################################
Отримати інформацію про title_en

Отримати інформацію про title_ru

Отримати інформацію про description_en

Отримати інформацію про description_ru

Отримати інформацію про items[0].deliveryLocation.latitude

Отримати інформацію про items[0].deliveryAddress.countryName_ru

Отримати інформацію про items[0].deliveryAddress.countryName_en

###############################################################################################################

Отримати інформацію про awards[0].complaintPeriod.endDate
    ${return_value}=   get element attribute        xpath=.//td[@style='display: none']@textContent
    ${return_value}=   trim data                    ${return_value}
    ${contract_date}=  convert to string  ${return_value}
    set global variable  ${contract_date}
    [return]  ${return_value}

Підтвердити підписання контракту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[1]} ==  ${1}
  ...      ${ARGUMENTS[2]} ==  ${0}
    reload page
    sleep  60
    wait until element is visible   award-negot-contract-0  60
    #натискаємо кнопку "Опублікувати договір"
    click element  award-negot-contract-0
    wait until element is visible   number  60
    ${contract_date_str}=           convert_datetime_to_new                            ${contract_date}
    ${contract_date_time}=          plus_1_min                                         ${contract_date}
    input text                      number                                             Договір номер 123/1
    #Заповнюємо "Дату підписання"
    input text                      xpath=(.//input[@class='md-datepicker-input'])[1]  ${contract_date_str}
    sleep  4
    clear element text              xpath=(//*[@id="timeInput"])[1]
    sleep  2
    input text                      xpath=(//*[@id="timeInput"])[1]                    ${contract_date_time}
    sleep  4
    #Переходимо у вікно "Підписати"
    click element                   xpath=(.//button[@type='submit'])[1]
    wait until element is visible   id=PKeyPassword    1000
    execute javascript              $(".form-horizontal").find("#PKeyFileInput").css("visibility", "visible")
    sleep  5
    choose file                     id=PKeyFileInput                            ${CURDIR}${/}Key-6.dat
    sleep  5
    input text                      id=PKeyPassword                             111111
    sleep  5
    select from list                id=CAsServersSelect                         Тестовий ЦСК АТ "ІІТ"
    sleep  5
    click element                   id=PKeyReadButton
    wait until element is enabled   id=SignDataButton   600
    sleep  1
    click element                   id=SignDataButton
    sleep  10

Відповісти на вимогу про виправлення умов закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${answer_data}
  ${resolution}=            get from dictionary         ${ARGUMENTS[3].data}                    resolution
  ${resolutionType}=        get from dictionary         ${ARGUMENTS[3].data}                    resolutionType
  ${tendererAction}=        get from dictionary         ${ARGUMENTS[3].data}                    tendererAction
  go to                     ${ViewTenderUrl}
  sleep                     30
  reload page
  sleep  5
  execute javascript                    angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  wait until element is visible         id=old-complaint-answer-  60
  click element                         id=old-complaint-answer-
  wait until element is visible         id=resolution  60
  input text                            id=resolution                        ${resolution}
  select from list by value             resolutionType                       ${resolutionType}
  sleep  2
  input text                            tendererAction                       ${tendererAction}
  click element                         xpath=.//button[@ladda='vm.saving']
  sleep  10

Відповісти на вимогу про виправлення умов лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${answer_data}
  ${resolution}=            get from dictionary         ${ARGUMENTS[3].data}                        resolution
  ${resolutionType}=        get from dictionary         ${ARGUMENTS[3].data}                        resolutionType
  ${tendererAction}=        get from dictionary         ${ARGUMENTS[3].data}                        tendererAction
  go to  ${ViewTenderUrl}
  sleep  30
  reload page
  sleep  5
  execute javascript                    angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  wait until element is visible         id=old-complaint-answer-  60
  click element                         id=old-complaint-answer-
  wait until element is visible         id=resolution  60
  input text                            id=resolution                        ${resolution}
  select from list by value             resolutionType                       ${resolutionType}
  sleep  2
  input text                            tendererAction                       ${tendererAction}
  click element                         xpath=.//button[@ladda='vm.saving']
  sleep  10

Відповісти на вимогу про виправлення визначення переможця
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${answer_data}
  ...      ${ARGUMENTS[4]} ==  ${award_index}
  ${resolution}=            get from dictionary         ${ARGUMENTS[3].data}                        resolution
  ${resolutionType}=        get from dictionary         ${ARGUMENTS[3].data}                        resolutionType
  ${tendererAction}=        get from dictionary         ${ARGUMENTS[3].data}                        tendererAction
  go to  ${ViewTenderUrl}
  sleep  30
  reload page
  sleep  5
  execute javascript                    angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  wait until element is visible         id=old-complaint-answer-  60
  click element                         id=old-complaint-answer-
  wait until element is visible         id=resolution  60
  input text                            id=resolution                        ${resolution}
  select from list by value             resolutionType                       ${resolutionType}
  sleep  2
  input text                            tendererAction                       ${tendererAction}
  click element                         xpath=.//button[@ladda='vm.saving']
  sleep  10

Створити вимогу про виправлення умов закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${claim}
  ...      ${ARGUMENTS[3]} ==  ${file_path}
  log to console  *
  log to console  !!! Починаємо "Створити вимогу про виправлення умов закупівлі" !!!
  ${title}=                      get from dictionary                   ${ARGUMENTS[2].data}        title
  ${description}=                get from dictionary                   ${ARGUMENTS[2].data}        description
  go to                          ${ViewTenderUrl}
  sleep  10
  wait until element is visible  claim-add  60
  sleep  3
  #Натискаємо кнопку "Створити вимогу"
  focus                          id=claim-add
  click element                  id=claim-add
  #Переходимо у вікно "Вимога до закупівлі"
#  wait until element is visible  title  60
  sleep  10
  focus                          title
  input text                     title                                 ${title}
  input text                     description                           ${description}
  sleep  2
  click element                  complaint-document-add
  sleep  5
  input text                     description-complaint-documents-0     PLACEHOLDER
  choose file                    id=file-complaint-documents-0         ${ARGUMENTS[3]}
  click element                  xpath=.//button[@type='submit']
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  ${complaint_id}=               execute javascript   return angular.element("div:contains('${title}')").parent("a")[0].id
  ${delim}=                      convert to string    t-
  ${complaint_id}=               parse_smth           ${complaint_id}  ${1}  ${delim}
  log to console  *
  log to console  Створено вимогу номер ${complaint_id}
  log to console  *
  log to console  !!! Закінчили "Створити вимогу про виправлення умов закупівлі" !!!
  [return]  ${complaint_id}

Створити вимогу про виправлення умов лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${claim}
  ...      ${ARGUMENTS[3]} ==  ${lot_id}
  ...      ${ARGUMENTS[4]} ==  ${file_path}
  log to console  *
  log to console  !!! Починаємо "Створити вимогу про виправлення умов лоту"  !!!
  ${title}=                      get from dictionary                   ${ARGUMENTS[2].data}        title
  ${description}=                get from dictionary                   ${ARGUMENTS[2].data}        description
  go to                          ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  5
  #Натискаємо кнопку "Створити вимогу"
  click element  claim-add
  #Переходимо у вікно "Вимога до закупівлі"
  wait until element is visible  id=relatedLot  60
  #Обираємо лот до якого створюється вимога
  click element                  id=relatedLot
  sleep  2
  click element                  xpath=(.//option[@class='ng-binding ng-scope'])[1]
  sleep  2
  input text                     title                                 ${title}
  input text                     description                           ${description}
  sleep  2
  click element                  complaint-document-add
  sleep  1
  click element                  complaint-document-add
  sleep  3
  input text                              description-complaint-documents-0     PLACEHOLDER
  choose file                             id=file-complaint-documents-0         ${ARGUMENTS[4]}
  click element                           xpath=.//button[@type='submit']
  #Очікуємо появи повідомлення
  wait until element is visible         xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  15
  ${complaint_id}=  execute javascript   return angular.element("div:contains('${title}')").parent("a")[0].id
  ${delim}=  convert to string  t-
  ${complaint_id}=  parse_smth  ${complaint_id}  ${1}  ${delim}
  log to console  *
  log to console  Створено вимогу до лоту номер ${complaint_id}
  log to console  *
  log to console  !!! Закінчили "Створити вимогу про виправлення умов лоту"  !!!
  [return]  ${complaint_id}

Отримати інформацію із скарги
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${tender_uaid}
  ...      ${ARGUMENTS[2]} ==  ${complaintID}
  ...      ${ARGUMENTS[3]} ==  ${field_name}
  ...      ${ARGUMENTS[4]} ==  ${award_index}
  go to  ${ViewTenderUrl}
  sleep  5
  log to console  *
  log to console  ${ARGUMENTS[2]}
  log to console  *
  execute javascript             angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  ${return_value}=  run keyword  Отримати інформацію про скарги ${ARGUMENTS[3]}
  [return]  ${return_value}

Отримати інформацію про скарги description
   wait until element is visible        xpath=.//div[@class='description-text ng-binding ng-scope']  60
   ${return_value}=   get text          xpath=.//div[@class='description-text ng-binding ng-scope']
   [return]  ${return_value}

Отримати інформацію про скарги title
   wait until element is visible        xpath=.//div[@class='description-text ng-binding ng-scope']  60
   ${return_value}=   get text          xpath=(.//div[@class='ng-binding flex'])[1]
   ${return_value}=   parse_smth        ${return_value}    ${1}   ${:}
   ${return_value}=   trim_data         ${return_value}
   [return]  ${return_value}

Отримати інформацію із документа до скарги
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${complaintID}
  ...      ${ARGUMENTS[3]} ==  ${doc_id}
  ...      ${ARGUMENTS[4]} ==  ${field}
  go to  ${ViewTenderUrl}
  sleep  10
  execute javascript                    angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  wait until element is visible         xpath=(.//button[@type='button']/span[@class='ng-binding ng-scope'])[9]  60
  click element                         xpath=(.//button[@type='button']/span[@class='ng-binding ng-scope'])[9]
  wait until element is visible         xpath=(.//a[@class='link-like ng-binding'])[8]   60
  ${return_value}=      get text        xpath=(.//a[@class='link-like ng-binding'])[8]
  [return]  ${return_value}

Отримати інформацію про скарги status
   wait until element is visible        id=complaint-status  60
   ${return_value}=  get value          id=complaint-status
   [return]  ${return_value}

Отримати інформацію про скарги resolutionType
   wait until element is visible        id=resolution-type  60
   ${return_value}=  get value          id=resolution-type
   [return]  ${return_value}

Отримати інформацію про скарги resolution
   wait until element is visible        xpath=(.//div[@class='description-text ng-binding ng-scope'])[2]          60
   ${return_value}=  get text           xpath=(.//div[@class='description-text ng-binding ng-scope'])[2]
   [return]  ${return_value}

Отримати інформацію про скарги satisfied
   wait until element is visible        xpath=.//div[@layout='row']/div[@flex='none']/span[@class='ng-binding']   60
   ${return_value}=  get text           xpath=.//div[@layout='row']/div[@flex='none']/span[@class='ng-binding']
   ${return_value}=  claim_status       ${return_value}
   [return]  ${return_value}

Отримати інформацію про скарги cancellationReason
   wait until element is visible        xpath=.//div[@class='description-text ng-binding']     60
   ${return_value}=  get text           xpath=.//div[@class='description-text ng-binding']
   [return]  ${return_value}

Отримати інформацію про скарги relatedLot
   wait until element is visible        id=related-lot  60
   ${return_value}=  get value          id=related-lot
   [return]  ${return_value}

Завантажити документ рішення кваліфікаційної комісії
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${file_path}
  ...      ${ARGUMENTS[2]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[3]} ==  ${0}
  go to  ${ViewTenderUrl}
  log to console  *
  log to console  ${ARGUMENTS[0]}
  log to console  ${ARGUMENTS[1]}
  log to console  ${ARGUMENTS[2]}
  log to console  ${ARGUMENTS[3]}
  log to console  *
  sleep  10
  execute javascript  $($('[id=award-active-0]')[0]).click()
  wait until element is visible  xpath=.//button[@ng-click='onDocumentAdd()']  60
  sleep  1
  click element  xpath=.//button[@ng-click='onDocumentAdd()']
  wait until element is visible  ${Поле "Тип документа" (Кваліфікація учасників)}
  select from list  ${Поле "Тип документа" (Кваліфікація учасників)}  Повідомлення
  sleep  1
  input text  description-award-document  Назва документу
  choose file  id=file-award-document  ${ARGUMENTS[1]}
  sleep  2
  click element  xpath=/html/body/div[1]/div/div/form/ng-transclude/div[3]/button[1]
  sleep  10

Підтвердити постачальника
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${file_path}
  ...      ${ARGUMENTS[2]} ==  ${0}
  go to  ${ViewTenderUrl}

Отримати інформацію із лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${object_id}
  ...      ${ARGUMENTS[3]} ==  ${field_name}
  go to  ${ViewTenderUrl}
  sleep  10
  ${return_value}=  get text  xpath=(.//div[@class='field-value word-break ng-binding flex-70'])[1]
  [return]  ${return_value}

Підтвердити вирішення вимоги про виправлення умов закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${confirmation_data}
  log to console  *
  log to console  !!! Починаємо "Підтвердити вирішення вимоги про виправлення умов закупівлі"  !!!
  go to  ${ViewTenderUrl}
  wait until element is visible         claim-add  60
  sleep  5
  execute javascript                    angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  #Кнопка "ПОГОДИТИСЬ З ВИРІШЕННЯМ"
  wait until element is visible         id=old-complaint-satisfy-  60
  click element                         id=old-complaint-satisfy-
  #кнопка "Погодитись з вирішенням"
  wait until element is visible         xpath=.//button[@type='submit']  60
  click element                         xpath=.//button[@type='submit']
  #Очікуємо появи повідомлення
  wait until element is visible         xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Підтвердити вирішення вимоги про виправлення умов закупівлі"  !!!

Підтвердити вирішення вимоги про виправлення умов лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['lot_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${confirmation_data}
  log to console  *
  log to console  !!! Починаємо "Підтвердити вирішення вимоги про виправлення умов лоту  !!!
  go to  ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  5
  execute javascript                    angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  wait until element is visible         id=old-complaint-satisfy-  60
  #кнопка "ПОГОДИТИСЬ З ВИРІШЕННЯМ"
  click element                         id=old-complaint-satisfy-
  #кнопка "Погодитись з вирішенням"
  wait until element is visible         xpath=.//button[@type='submit']  60
  click element                         xpath=.//button[@type='submit']
  #Очікуємо появи повідомлення
  wait until element is visible         xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Підтвердити вирішення вимоги про виправлення умов лоту  !!!

Створити чернетку вимоги про виправлення умов закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${claim}
  log to console  *
  log to console  !!! Починаємо "Створити чернетку вимоги про виправлення умов закупівлі"  !!!
  ${title}=                      get from dictionary                   ${ARGUMENTS[2].data}        title
  ${description}=                get from dictionary                   ${ARGUMENTS[2].data}        description
  go to                          ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  3

  #Натискаємо кнопку "Створити вимогу"
  click element  claim-add
  #Переходимо у вікно "Вимога до закупівлі"
  wait until element is visible  title  60
  input text                     title                                 ${title}
  input text                     description                           ${description}
  #Обираємо чекбокс "ПІДПИСАТИ"
  click element                  xpath=.//md-checkbox/div[@class='md-container']
  sleep  1
  #Кнопка "Створити вимогу"
  click element                  xpath=.//button[@type='submit']
  #Очікуємо появу поля "Пароль" та скасовуємо підписання
  wait until element is visible  id=PKeyPassword  120
  click element                  xpath=(.//button[@ng-click='cancel()'])[1]
  #Очікуємо появи повідомлення
  wait until element is visible         xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  15
  ${complaint_id}=  execute javascript   return angular.element("div:contains('${title}')").parent("a")[0].id
  ${delim}=  convert to string  t-
  ${complaint_id}=  parse_smth  ${complaint_id}  ${1}  ${delim}
  log to console  *
  log to console  Створили чернетку вимоги до закупівлі номер ${complaint_id}
  log to console  *
  log to console  !!! Закінчили "Створити чернетку вимоги про виправлення умов закупівлі"  !!!
  [return]  ${complaint_id}

Скасувати вимогу про виправлення умов закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${cancellation_data}
  log to console  *
  log to console  !!! Починаємо "Скасувати вимогу про виправлення умов закупівлі"  !!!
  ${cancellationReason}=         get from dictionary           ${ARGUMENTS[3].data}        cancellationReason
  go to  ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  5
  execute javascript             angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  #Кнопка "ВІДКЛИКАТИ ВИМОГУ"
  wait until element is visible  id=old-complaint-cancel-  60
  click element                  id=old-complaint-cancel-
  wait until element is visible  id=cancellationReason     60
  input text                     id=cancellationReason     ${cancellationReason}
  sleep  1
  click element                  xpath=(.//button[@type='submit'])
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Скасувати вимогу про виправлення умов закупівлі"  !!!

Створити чернетку вимоги про виправлення умов лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${claim}
  ...      ${ARGUMENTS[3]} ==  ${lot_id}
  log to console  *
  log to console  !!! Починаємо "Створити чернетку вимоги про виправлення умов лоту"  !!!
  ${title}=                      get from dictionary                   ${ARGUMENTS[2].data}        title
  ${description}=                get from dictionary                   ${ARGUMENTS[2].data}        description
  go to  ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  10
  #Натискаємо кнопку "Створити вимогу"
  click element                  claim-add
  #Переходимо у вікно "Вимога до закупівлі"
  wait until element is visible  title  60
  #Обираємо лот
  click element                  id=relatedLot
  sleep  2
  click element                  xpath=(.//option[@class='ng-binding ng-scope'])[1]
  sleep  2
  input text                     title                                 ${title}
  input text                     description                           ${description}
  #Обираємо чекбокс "ПІДПИСАТИ"
  click element                  xpath=.//md-checkbox/div[@class='md-container']
  sleep  1
  #Кнопка "Створити вимогу"
  click element                  xpath=.//button[@type='submit']
  #Очікуємо появу поля "Пароль" та скасовуємо підписання
  wait until element is visible  id=PKeyPassword  120
  click element                  xpath=(.//button[@ng-click='cancel()'])[1]
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  15
  ${complaint_id}=  execute javascript   return angular.element("div:contains('${title}')").parent("a")[0].id
  ${delim}=  convert to string  t-
  ${complaint_id}=  parse_smth  ${complaint_id}  ${1}  ${delim}
  log to console  *
  log to console  Створили чернетку вимоги до лоту номер ${complaint_id}
  log to console  *
  log to console  !!! Закінчили "Створити чернетку вимоги про виправлення умов лоту"  !!!
  [return]  ${complaint_id}

Перетворити вимогу про виправлення умов закупівлі в скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${escalation_data}
  log to console  *
  log to console  !!! Починаємо "Перетворити вимогу про виправлення умов закупівлі в скаргу"  !!!
  go to  ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  5
  execute javascript                     angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  #Кнопка "ПЕРЕТВОРИТИ ВИМОГУ В СКАРГУ"
  wait until element is visible          id=old-complaint-reject-  60
  click element                          id=old-complaint-reject-
  wait until element is visible          xpath=.//button[@ladda='vm.saving']  60
  click element                          xpath=.//button[@ladda='vm.saving']
  #Очікуємо появи повідомлення
  wait until element is visible          xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Перетворити вимогу про виправлення умов закупівлі в скаргу"  !!!

Перетворити вимогу про виправлення умов лоту в скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${escalation_data}
  log to console  *
  log to console  !!! Починаємо "Перетворити вимогу про виправлення умов лоту в скаргу"  !!!
  go to  ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  5
  execute javascript                     angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  #Кнопка "ПЕРЕТВОРИТИ ВИМОГУ В СКАРГУ"
  wait until element is visible          id=old-complaint-reject-  60
  click element                          id=old-complaint-reject-
  wait until element is visible          xpath=.//button[@ladda='vm.saving']  60
  click element                          xpath=.//button[@ladda='vm.saving']
  #Очікуємо появи повідомлення
  wait until element is visible          xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Перетворити вимогу про виправлення умов лоту в скаргу"  !!!

Подати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${bid}
  ...      ${ARGUMENTS[3]} ==  ${lots_ids}
  ...      ${ARGUMENTS[4]} ==  ${features_ids}
  ${amount}=        get from dictionary            ${ARGUMENTS[2].data.lotValues[0].value}       amount
  ${amount_str}=    convert to string              ${amount}
  go to  ${ViewTenderUrl}
  wait until element is visible  xpath=.//span[@ng-if='data.status']  60
  #Кнопка "Додати пропозицію"
  execute javascript             angular.element("#set-participate-in-lot").click()
  sleep  3
  log to console  *
  ${test_var}=          get text            xpath=.//span[@dataanchor='amount']
  ${test_var}=          get_numberic_part   ${test_var}
  ${1_grn}=             set variable        ${1}
  ${test_var}=          evaluate            ${test_var}-${1_grn}
  ${test_var_str}=      convert to string   ${test_var}
  log to console   ${test_var_str}
  log to console  *
  input text                     id=lot-amount-0       ${test_var_str}
  sleep  5
  #Кнопка "Відправити пропозиції"
  execute javascript             angular.element("#tender-update-bid").click()
  wait until element is visible  xpath=.//button[@ng-click='ok()']  60
  click element                  xpath=.//button[@ng-click='ok()']
  sleep  10
  log to console  !!! Закінчили "Подати цінову пропозицію"  !!!

Створити вимогу про виправлення визначення переможця
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${claim}
  ...      ${ARGUMENTS[3]} ==  ${award_index}
  ...      ${ARGUMENTS[4]} ==  ${file_path}
  log to console  *
  log to console  !!! Почали "Створити вимогу про виправлення визначення переможця"  !!!
  ${title}=                      get from dictionary                   ${ARGUMENTS[2].data}        title
  ${description}=                get from dictionary                   ${ARGUMENTS[2].data}        description

  go to  ${ViewTenderUrl}
  wait until element is visible  xpath=.//span[@ng-if='data.status']          60
  SLEEP  10
  execute javascript             angular.element("#award-claim-").click()
  wait until element is visible  id=title                 60
  input text                     id=title                 ${title}
  input text                     id=description           ${description}
  sleep  2
  click element                  complaint-document-add
  sleep  5
  input text                              description-complaint-documents-0     PLACEHOLDER
  choose file                             id=file-complaint-documents-0         ${ARGUMENTS[4]}
  click element                           xpath=.//button[@type='submit']
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  10
  ${complaint_id}=  execute javascript   return angular.element("div:contains('${title}')").parent("a")[0].id
  ${delim}=  convert to string  t-
  ${complaint_id}=  parse_smth  ${complaint_id}  ${1}  ${delim}
  log to console  *
  log to console  Вимога про виправлення переможця номер ${complaint_id}
  log to console  *
  log to console  !!! Закінчили "Створити вимогу про виправлення визначення переможця"  !!!
  [return]  ${complaint_id}

Підтвердити вирішення вимоги про виправлення визначення переможця
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${confirmation_data}
  ...      ${ARGUMENTS[4]} ==  ${award_index}
  log to console  *
  log to console  !!! Підтвердити вирішення вимоги про виправлення визначення переможця  !!!
  go to  ${ViewTenderUrl}
  wait until element is visible         xpath=.//span[@ng-if='data.status']  60
  sleep  10
  execute javascript                    angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  wait until element is visible         id=old-complaint-satisfy-  60
  #кнопка "Погодитись з рішенням"
  click element                         id=old-complaint-satisfy-
  wait until element is visible         xpath=.//button[@ladda='vm.saving']  60
  click element                         xpath=.//button[@ladda='vm.saving']
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили Підтвердити вирішення вимоги про виправлення визначення переможця  !!!

Створити чернетку вимоги про виправлення визначення переможця
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${claim}
  ...      ${ARGUMENTS[3]} ==  ${award_index}
  log to console  *
  log to console  !!! Починаємо "Створити чернетку вимоги про виправлення визначення переможця"  !!!
  ${title}=                      get from dictionary                   ${ARGUMENTS[2].data}        title
  ${description}=                get from dictionary                   ${ARGUMENTS[2].data}        description
  go to  ${ViewTenderUrl}
  #Натискаємо кнопку "Створити вимогу"
  wait until element is visible  xpath=.//span[@ng-if='data.status']  60
  sleep  10
  execute javascript             angular.element("#award-claim-").click()
  #Переходимо у вікно "Вимога до закупівлі"
  wait until element is visible  title  60
  input text                     title                                 ${title}
  input text                     description                           ${description}
  #Обираємо чекбокс "ПІДПИСАТИ"
  click element                  xpath=.//md-checkbox/div[@class='md-container']
  sleep  1
  #Кнопка "Створити вимогу"
  click element                  xpath=.//button[@type='submit']
  #Очікуємо появу поля "Пароль" та скасовуємо підписання
  wait until element is visible  id=PKeyPassword  120
  click element                  xpath=(.//button[@ng-click='cancel()'])[1]
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  10
  ${complaint_id}=  execute javascript   return angular.element("div:contains('${title}')").parent("a")[0].id
  ${delim}=  convert to string  t-
  ${complaint_id}=  parse_smth  ${complaint_id}  ${1}  ${delim}
  log to console  *
  log to console  Чернетка вимоги про виправлення визначення переможця номер ${complaint_id}
  log to console  *
  log to console  !!! Закінчили "Створити чернетку вимоги про виправлення визначення переможця"  !!!
  [return]  ${complaint_id}

Скасувати вимогу про виправлення визначення переможця
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${cancellation_data}
  ...      ${ARGUMENTS[4]} ==  ${award_index}
  log to console  *
  log to console  !!! Починаємо "Скасувати вимогу про виправлення визначення переможця"  !!!
  ${cancellationReason}=       get from dictionary  ${ARGUMENTS[3].data}        cancellationReason
  go to  ${ViewTenderUrl}
  wait until element is visible  xpath=.//span[@ng-if='data.status']  60
  sleep  10
  execute javascript                     angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  wait until element is visible          id=old-complaint-cancel-  60
  click element                          id=old-complaint-cancel-
  wait until element is visible          id=cancellationReason     60
  input text      id=cancellationReason  ${cancellationReason}
  sleep  1
  click element                  xpath=(.//button[@type='submit'])
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Скасувати вимогу про виправлення визначення переможця"  !!!

Перетворити вимогу про виправлення визначення переможця в скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${escalation_data}
  ...      ${ARGUMENTS[4]} ==  ${award_index}
  log to console  *
  log to console  !!! Починаємо "Перетворити вимогу про виправлення визначення переможця в скаргу"  !!!
  go to  ${ViewTenderUrl}
  wait until element is visible  xpath=.//span[@ng-if='data.status']  60
  sleep  10
  execute javascript                     angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  #Кнопка "ПЕРЕТВОРИТИ ВИМОГУ В СКАРГУ"
  wait until element is visible          id=old-complaint-reject-  60
  click element                          id=old-complaint-reject-
  wait until element is visible          xpath=.//button[@ladda='vm.saving']  60
  click element                          xpath=.//button[@ladda='vm.saving']
  #Очікуємо появи повідомлення
  wait until element is visible          xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Перетворити вимогу про виправлення визначення переможця в скаргу"  !!!

Скасувати вимогу про виправлення умов лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${cancellation_data}
  log to console  *
  log to console  !!! Починаємо "Скасувати вимогу про виправлення умов лоту"  !!!
  ${cancellationReason}=       get from dictionary    ${ARGUMENTS[3].data}        cancellationReason
  go to  ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  5
  execute javascript                     angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  #Кнопка "ВІДКЛИКАТИ ВИМОГУ"
  wait until element is visible  id=old-complaint-cancel-  60
  click element                  id=old-complaint-cancel-
  wait until element is visible  id=cancellationReason
  input text                     id=cancellationReason     ${cancellationReason}
  sleep  1
  click element                  xpath=(.//button[@type='submit'])
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Скасувати вимогу про виправлення умов лоту"  !!!













