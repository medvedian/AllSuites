*** Settings ***
Library  Selenium2Library
Library  accept_service.py
Library   Collections
Library   DateTime
Library   String

*** Variables ***
${locator.edit.tenderPeriod.endDate}  id=timeInput
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
#    run keyword if  '${TENDER_TYPE}' == 'negotiation'            Підготувати тендер дату   ${tender_data}
#    run keyword if  '${TENDER_TYPE}' == 'aboveThresholdUA'       Підготувати тендер дату   ${tender_data}
#    run keyword if  '${TENDER_TYPE}' == 'aboveThresholdEU'       Підготувати тендер дату   ${tender_data}

    run keyword if  '${username}' == 'accept_Owner'      Підготувати тендер дату   ${tender_data}

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
  run keyword if  '${TENDER_TYPE}' == 'negotiation'         Створити тендер negotiation        @{ARGUMENTS}
  run keyword if  '${TENDER_TYPE}' == 'complaints'          Створити тендер complaints         @{ARGUMENTS}
  run keyword if  '${TENDER_TYPE}' == 'aboveThresholdEU'    Створити тендер aboveThresholdEU   @{ARGUMENTS}
  run keyword if  '${TENDER_TYPE}' == 'aboveThresholdUA'    Створити тендер aboveThresholdUA   @{ARGUMENTS}
  [return]  ${TENDER_UA}

Створити тендер aboveThresholdUA
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
  log  ${ARGUMENTS[1]}
  log to console  ${ARGUMENTS[0]}
    ${title}=                             Get From Dictionary             ${ARGUMENTS[1].data}                        title
    ${title_en}=                          Get From Dictionary             ${ARGUMENTS[1].data}                        title_en
    ${description}=                       Get From Dictionary             ${ARGUMENTS[1].data}                        description
    ${description_en}=                    Get From Dictionary             ${ARGUMENTS[1].data}                        description_en
    ${vat}=                               get from dictionary             ${ARGUMENTS[1].data.value}                  valueAddedTaxIncluded
    ${currency}=                          Get From Dictionary             ${ARGUMENTS[1].data.value}                  currency
    ${lots}=                              Get From Dictionary             ${ARGUMENTS[1].data}                        lots
    ${lot_description}=                   Get From Dictionary             ${lots[0]}                                  description
    ${lot_title}=                         Get From Dictionary             ${lots[0]}                                  title
    set global variable  ${lot_title}
    ${lot_title_en}=                      Get From Dictionary             ${lots[0]}                                  title_en
    ${lot_amount}=                        adapt_numbers                   ${ARGUMENTS[1].data.lots[0].value.amount}
    ${lot_amount_str}=                    convert to string               ${lot_amount}
    log to console  *
    log to console  ${lot_amount_str}
    ${lot_minimal_step_amount}=           adapt_numbers                   ${lots[0].minimalStep.amount}
    ${lot_minimal_step_amount_str}=       convert to string               ${lot_minimal_step_amount}
    log to console  ${lot_minimal_step_amount_str}
    ${items}=                             Get From Dictionary             ${ARGUMENTS[1].data}                        items
    ${item_description}=                  Get From Dictionary             ${items[0]}                                 description
    set global variable  ${item_description}
    ${item_description_en}=               Get From Dictionary             ${items[0]}                                 description_en
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
    #період подачі пропозицій
    ${tenderPeriod_endDate}=              Get From Dictionary             ${ARGUMENTS[1].data.tenderPeriod}           endDate
    #період доставки
    ${delivery_startDate}=                Get From Dictionary             ${items[0].deliveryDate}                    startDate
    ${delivery_endDate}=                  Get From Dictionary             ${items[0].deliveryDate}                    endDate
    #конвертація дат та часу
    ${tenderPeriod_endDate_str}=          convert_datetime_to_new         ${tenderPeriod_endDate}
	${tenderPeriod_endDate_time}=         plus_1_min    ${tenderPeriod_endDate}
    ${delivery_StartDate_str}=            convert_datetime_to_new         ${delivery_startDate}
	${delivery_StartDate_time}=           convert_datetime_to_new_time    ${delivery_startDate}
    ${delivery_endDate_str}=              convert_datetime_to_new         ${delivery_endDate}
	${delivery_endDate_time}=             convert_datetime_to_new_time    ${delivery_endDate}
    ${features}=                          Get From Dictionary             ${ARGUMENTS[1].data}                        features
    #Нецінові крітерії лоту
    ${lot_features_title}=                Get From Dictionary             ${features[0]}                              title
    ${lot_features_description} =         Get From Dictionary             ${features[0]}                              description
    ${lot_features_of}=                   Get From Dictionary             ${features[0]}                              featureOf
    ${lot_non_price_1_value}=             convert to number               ${features[0].enum[0].value}
    ${lot_non_price_1_value}=             percents                        ${lot_non_price_1_value}
    ${lot_non_price_1_value}=             convert to string               ${lot_non_price_1_value}
    ${lot_non_price_1_title}=             Get From Dictionary             ${features[0].enum[0]}                      title
    ${lot_non_price_2_value}=             convert to number               ${features[0].enum[1].value}
    ${lot_non_price_2_value}=             percents                        ${lot_non_price_2_value}
    ${lot_non_price_2_value}=             convert to string               ${lot_non_price_2_value}
    ${lot_non_price_2_title}=             Get From Dictionary             ${features[0].enum[1]}                      title
    ${lot_non_price_3_value}=             convert to number               ${features[0].enum[2].value}
    ${lot_non_price_3_value}=             percents                        ${lot_non_price_3_value}
    ${lot_non_price_3_value}=             convert to string               ${lot_non_price_3_value}
    ${lot_non_price_3_title}=             Get From Dictionary             ${features[0].enum[2]}                      title
    #Нецінові крітерії тендеру
    ${tender_features_title}=             Get From Dictionary             ${features[1]}                              title
    ${tender_features_description} =      Get From Dictionary             ${features[1]}                              description
    ${tender_features_of}=                Get From Dictionary             ${features[1]}                              featureOf
    ${tender_non_price_1_value}=          convert to number               ${features[1].enum[0].value}
    ${tender_non_price_1_value}=          percents                        ${tender_non_price_1_value}
    ${tender_non_price_1_value}=          convert to string               ${tender_non_price_1_value}
    ${tender_non_price_1_title}=          Get From Dictionary             ${features[1].enum[0]}                      title
    ${tender_non_price_2_value}=          convert to number               ${features[1].enum[1].value}
    ${tender_non_price_2_value}=          percents                        ${tender_non_price_2_value}
    ${tender_non_price_2_value}=          convert to string               ${tender_non_price_2_value}
    ${tender_non_price_2_title}=          Get From Dictionary             ${features[1].enum[1]}                      title
    ${tender_non_price_3_value}=          convert to number               ${features[1].enum[2].value}
    ${tender_non_price_3_value}=          percents                        ${tender_non_price_3_value}
    ${tender_non_price_3_value}=          convert to string               ${tender_non_price_3_value}
    ${tender_non_price_3_title}=          Get From Dictionary             ${features[1].enum[2]}                      title
    #Нецінові крітерії айтему
    ${item_features_title}=               Get From Dictionary             ${features[2]}                              title
    ${item_features_description} =        Get From Dictionary             ${features[2]}                              description
    ${item_features_of}=                  Get From Dictionary             ${features[2]}                              featureOf
    ${item_non_price_1_value}=            convert to number               ${features[2].enum[0].value}
    ${item_non_price_1_value}=            percents                        ${item_non_price_1_value}
    ${item_non_price_1_value}             convert to string               ${item_non_price_1_value}
    ${item_non_price_1_title}=            Get From Dictionary             ${features[2].enum[0]}                      title
    ${item_non_price_2_value}=            convert to number               ${features[2].enum[1].value}
    ${item_non_price_2_value}=            percents                        ${item_non_price_2_value}
    ${item_non_price_2_value}=            convert to string               ${item_non_price_2_value}
    ${item_non_price_2_title}=            Get From Dictionary             ${features[2].enum[1]}                      title
    ${item_non_price_3_value}=            convert to number               ${features[2].enum[2].value}
    ${item_non_price_3_value}=            percents                        ${item_non_price_3_value}
    ${item_non_price_3_value}=            convert to string               ${item_non_price_3_value}=
    ${item_non_price_3_title}=            Get From Dictionary             ${features[2].enum[2]}                      title
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
    click element  id=procurementMethodType
    sleep  2
    click element  xpath=//div [@class='md-select-menu-container md-active md-clickable']//md-select-menu [@class = '_md']//md-content [@class = '_md']//md-option[2]
    input text  ${Поле "Узагальнена назва закупівлі"}  ${title}
    sleep  2
    run keyword if       '${vat}'     click element      id=tender-value-vat
    sleep  1
    input text  id=description     ${description}
    sleep  1
    #Заповнюємо дати
    input text  xpath=(.//input[@class='md-datepicker-input'])[1]                       ${tenderPeriod_endDate_str}
    sleep  3
    input text   xpath=(//*[@id="timeInput"])[1]                                        ${tenderPeriod_endDate_time}
    sleep  3
    #Переходимо на вкладку "Лоти закупівлі"
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
    Execute Javascript    $($('[id=cpv]')[0]).scope().value.classification = {id: "${item_id}", description: "${item_descr}", scheme: "${item_scheme}"};
    sleep  2
    #Заповнюємо додаткові коди
    run keyword and ignore error  Заповнюємо додаткові коди
    sleep  2
    #Заповнюємо поле "Одиниці виміру"
    Select From List  id=unit-unit--  ${item_unit}
    #Заповнюємо датапікери
    input text      xpath=(*//input[@class='md-datepicker-input'])[2]                   ${delivery_StartDate_str}
    sleep  2
    input text      xpath=(//*[@id="timeInput"])[2]                                     ${delivery_StartDate_time}
    sleep  2
    input text      xpath=(.//input[@class='md-datepicker-input'])[3]                   ${delivery_endDate_str}
    sleep  2
    input text      xpath=(//*[@id="timeInput"])[3]                                     ${delivery_endDate_time}
    sleep  2
    #Заповнюємо адресу доставки
    select from list  id=countryName.value.deliveryAddress--                            ${item_countryName}
    input text        id=streetAddress.value.deliveryAddress--                          ${item_streetAddress}
    input text        id=locality.value.deliveryAddress--                               ${item_locality}
    input text        id=region.value.deliveryAddress--                                 ${item_region}
    input text        id=postalCode.value.deliveryAddress--                             ${item_postalCode}
    sleep  2

    #Переходимо на вкладку "Інші крітерії оцінки"
    Execute Javascript          angular.element("md-tab-item")[2].click()
    sleep  3
    #заповнюємо нецінові крітерії лоту
    click element               featureAddAction
    sleep  1
    input text                  xpath=(//*[@id="feature.title."])[1]                    ${lot_features_title}
    input text                  xpath=(//*[@id="feature.description."])[1]              ${lot_features_description}
    select from list by value   xpath=(//*[@id="feature.featureOf."])[1]                ${lot_features_of}
    sleep  2
    select from list by label   xpath=//*[@id="feature.relatedItem."][1]                ${lot_title}
    sleep  2
    click element               xpath=(//*[@id="enumAddAction"])[1]
    sleep  1
    input text                  enum.title.0.0                                          ${lot_non_price_1_title}
    input text                  enum.value.0.0                                          ${lot_non_price_1_value}
    click element               xpath=(//*[@id="enumAddAction"])[1]
    sleep  1
    input text                  enum.title.0.1                                          ${lot_non_price_2_title}
    input text                  enum.value.0.1                                          ${lot_non_price_2_value}
    click element               xpath=(//*[@id="enumAddAction"])[1]
    sleep  1
    input text                  enum.title.0.2                                          ${lot_non_price_3_title}
    input text                  enum.value.0.2                                          ${lot_non_price_3_value}

    Execute Javascript    angular.element("md-tab-item")[3].click()
    sleep  3
    Execute Javascript    angular.element("md-tab-item")[2].click()
    sleep  3

    #заповнюємо нецінові крітерії тендеру
    click element               featureAddAction
    sleep  1
    input text                  xpath=(//*[@id="feature.title."])[2]                    ${tender_features_title}
    input text                  xpath=(//*[@id="feature.description."])[2]              ${tender_features_description}
    select from list by value   xpath=(//*[@id="feature.featureOf."])[2]                ${tender_features_of}
    sleep  2
    click element               xpath=(//*[@id="enumAddAction"])[2]
    sleep  1
    input text                  enum.title.1.0                                          ${tender_non_price_1_title}
    input text                  enum.value.1.0                                          ${tender_non_price_1_value}
    click element               xpath=(//*[@id="enumAddAction"])[2]
    sleep  1
    input text                  enum.title.1.1                                          ${tender_non_price_2_title}
    input text                  enum.value.1.1                                          ${tender_non_price_2_value}
    click element               xpath=(//*[@id="enumAddAction"])[2]
    sleep  1
    input text                  enum.title.1.2                                          ${tender_non_price_3_title}
    input text                  enum.value.1.2                                          ${tender_non_price_3_value}
    Execute Javascript    angular.element("md-tab-item")[3].click()
    sleep  3
    Execute Javascript    angular.element("md-tab-item")[2].click()
    sleep  3
    #заповнюємо нецінові крітерії айтему
    click element               featureAddAction
    sleep  1
    input text                  xpath=(//*[@id="feature.title."])[3]                    ${item_features_title}
    input text                  xpath=(//*[@id="feature.description."])[3]              ${item_features_description}
    select from list by value   xpath=(//*[@id="feature.featureOf."])[3]                ${item_features_of}
    sleep  3
    select from list by label   xpath=(//*[@id="feature.relatedItem."])[2]                ${item_description}
    sleep  3
    click element               xpath=(//*[@id="enumAddAction"])[3]
    sleep  1
    input text                  enum.title.2.0                                          ${item_non_price_1_title}
    input text                  enum.value.2.0                                          ${item_non_price_1_value}
    click element               xpath=(//*[@id="enumAddAction"])[3]
    sleep  1
    input text                  enum.title.2.1                                          ${item_non_price_2_title}
    input text                  enum.value.2.1                                          ${item_non_price_2_value}
    click element               xpath=(//*[@id="enumAddAction"])[3]
    sleep  1
    input text                  enum.title.2.2                                          ${item_non_price_3_title}
    input text                  enum.value.2.2                                          ${item_non_price_3_value}

    # Переходимо на вкладку "Контактна особа"
    Execute Javascript    angular.element("md-tab-item")[3].click()
    sleep  3
    input text            procuringEntityContactPointName                               ${contact_point_name}
    input text            procuringEntityContactPointTelephone                          ${contact_point_phone}
    input text            procuringEntityContactPointFax                                ${contact_point_fax}
    input text            procuringEntityContactPointEmail                              ${contact_point_email}
    input text            procurementMethodDetails                                      ${acceleration_mode}
#    input text            submissionMethodDetails                                       quick(mode:fast-forward)
    input text            mode                                                          test
    sleep  3
    click button  tender-apply
    sleep  3
    ${NewTenderUrl}=  Execute Javascript  return window.location.href
    SET GLOBAL VARIABLE          ${NewTenderUrl}
    sleep  4
    wait until element is visible  ${Поле "Узагальнена назва закупівлі"}  30
    click button                   ${Кнопка "Опублікувати"}
    wait until element is visible  ${Кнопка "Так" у попап вікні}  60
    click element                  ${Кнопка "Так" у попап вікні}
    #Очікуємо появи повідомлення
    wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
    sleep  5
    ${localID}=    get_local_id_from_url        ${NewTenderUrl}
    ${hrefToTender}=    Evaluate    "/dashboard/tender-drafts/" + str(${localID})
    Wait Until Page Contains Element    xpath=//a[@href="${hrefToTender}"]    30
    Go to  ${NewTenderUrl}
	Wait Until Page Contains Element  id=tenderUID    100
	Wait Until Page Contains Element  id=tenderID     100
    ${tender_id}=  Get Text  xpath=//a[@id='tenderUID']
    log to console  *
    log to console  ${tender_id}
    log to console  *
    ${TENDER_UA}=  Get Text  id=tenderID
    set global variable  ${TENDER_UA}
    ${ViewTenderUrl}=  assemble_viewtender_url  ${NewTenderUrl}  ${tender_id}
	SET GLOBAL VARIABLE                         ${ViewTenderUrl}

Створити тендер aboveThresholdEU
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...      ${ARGUMENTS[0]} ==  username
    ...      ${ARGUMENTS[1]} ==  tender_data
    log to console  *
    log to console  починаємо "Створити тендер aboveThresholdEU"
    ${title}=                             Get From Dictionary             ${ARGUMENTS[1].data}                        title
    ${title_en}=                          Get From Dictionary             ${ARGUMENTS[1].data}                        title_en
    ${description}=                       Get From Dictionary             ${ARGUMENTS[1].data}                        description
    ${description_en}=                    Get From Dictionary             ${ARGUMENTS[1].data}                        description_en
    ${vat}=                               get from dictionary             ${ARGUMENTS[1].data.value}                  valueAddedTaxIncluded
    ${currency}=                          Get From Dictionary             ${ARGUMENTS[1].data.value}                  currency
    ${lots}=                              Get From Dictionary             ${ARGUMENTS[1].data}                        lots
    ${lot_description}=                   Get From Dictionary             ${lots[0]}                                  description
    ${lot_title}=                         Get From Dictionary             ${lots[0]}                                  title
    set global variable  ${lot_title}
    ${lot_title_en}=                      Get From Dictionary             ${lots[0]}                                  title_en
#    ${lot_amount}=                        adapt_numbers                   ${ARGUMENTS[1].data.lots[0].value.amount}
    ${lot_amount}=                        add_second_sign_after_point     ${ARGUMENTS[1].data.lots[0].value.amount}
    ${lot_amount_str}=                    convert to string               ${lot_amount}
    ${lot_minimal_step_amount}=           adapt_numbers                   ${lots[0].minimalStep.amount}
    ${lot_minimal_step_amount_str}=       convert to string               ${lot_minimal_step_amount}
    ${items}=                             Get From Dictionary             ${ARGUMENTS[1].data}                        items
    ${item_description}=                  Get From Dictionary             ${items[0]}                                 description
    ${item_description_en}=               Get From Dictionary             ${items[0]}                                 description_en
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
    #період подачі пропозицій
    ${tenderPeriod_endDate}=              Get From Dictionary             ${ARGUMENTS[1].data.tenderPeriod}           endDate
    #період доставки
    ${delivery_startDate}=                Get From Dictionary             ${items[0].deliveryDate}                    startDate
    ${delivery_endDate}=                  Get From Dictionary             ${items[0].deliveryDate}                    endDate
    #конвертація дат та часу
    ${tenderPeriod_endDate_str}=          convert_datetime_to_new         ${tenderPeriod_endDate}
	${tenderPeriod_endDate_time}=         plus_20_min    ${tenderPeriod_endDate}
    ${delivery_StartDate_str}=            convert_datetime_to_new         ${delivery_startDate}
	${delivery_StartDate_time}=           convert_datetime_to_new_time    ${delivery_startDate}
    ${delivery_endDate_str}=              convert_datetime_to_new         ${delivery_endDate}
	${delivery_endDate_time}=             convert_datetime_to_new_time    ${delivery_endDate}
    ${features}=                          Get From Dictionary             ${ARGUMENTS[1].data}                        features
    #Нецінові крітерії лоту
    ${lot_features_title}=                Get From Dictionary             ${features[0]}                              title
    ${lot_features_description} =         Get From Dictionary             ${features[0]}                              description
    ${lot_features_of}=                   Get From Dictionary             ${features[0]}                              featureOf
    ${lot_non_price_1_value}=             convert to number               ${features[0].enum[0].value}
    ${lot_non_price_1_value}=             percents                        ${lot_non_price_1_value}
    ${lot_non_price_1_value}=             convert to string               ${lot_non_price_1_value}
    ${lot_non_price_1_title}=             Get From Dictionary             ${features[0].enum[0]}                      title
    ${lot_non_price_2_value}=             convert to number               ${features[0].enum[1].value}
    ${lot_non_price_2_value}=             percents                        ${lot_non_price_2_value}
    ${lot_non_price_2_value}=             convert to string               ${lot_non_price_2_value}
    ${lot_non_price_2_title}=             Get From Dictionary             ${features[0].enum[1]}                      title
    ${lot_non_price_3_value}=             convert to number               ${features[0].enum[2].value}
    ${lot_non_price_3_value}=             percents                        ${lot_non_price_3_value}
    ${lot_non_price_3_value}=             convert to string               ${lot_non_price_3_value}
    ${lot_non_price_3_title}=             Get From Dictionary             ${features[0].enum[2]}                      title
    #Нецінові крітерії тендеру
    ${tender_features_title}=             Get From Dictionary             ${features[1]}                              title
    ${tender_features_description} =      Get From Dictionary             ${features[1]}                              description
    ${tender_features_of}=                Get From Dictionary             ${features[1]}                              featureOf
    ${tender_non_price_1_value}=          convert to number               ${features[1].enum[0].value}
    ${tender_non_price_1_value}=          percents                        ${tender_non_price_1_value}
    ${tender_non_price_1_value}=          convert to string               ${tender_non_price_1_value}
    ${tender_non_price_1_title}=          Get From Dictionary             ${features[1].enum[0]}                      title
    ${tender_non_price_2_value}=          convert to number               ${features[1].enum[1].value}
    ${tender_non_price_2_value}=          percents                        ${tender_non_price_2_value}
    ${tender_non_price_2_value}=          convert to string               ${tender_non_price_2_value}
    ${tender_non_price_2_title}=          Get From Dictionary             ${features[1].enum[1]}                      title
    ${tender_non_price_3_value}=          convert to number               ${features[1].enum[2].value}
    ${tender_non_price_3_value}=          percents                        ${tender_non_price_3_value}
    ${tender_non_price_3_value}=          convert to string               ${tender_non_price_3_value}
    ${tender_non_price_3_title}=          Get From Dictionary             ${features[1].enum[2]}                      title
    #Нецінові крітерії айтему
    ${item_features_title}=               Get From Dictionary             ${features[2]}                              title
    ${item_features_description} =        Get From Dictionary             ${features[2]}                              description
    ${item_features_of}=                  Get From Dictionary             ${features[2]}                              featureOf
    ${item_non_price_1_value}=            convert to number               ${features[2].enum[0].value}
    ${item_non_price_1_value}=            percents                        ${item_non_price_1_value}
    ${item_non_price_1_value}             convert to string               ${item_non_price_1_value}
    ${item_non_price_1_title}=            Get From Dictionary             ${features[2].enum[0]}                      title
    ${item_non_price_2_value}=            convert to number               ${features[2].enum[1].value}
    ${item_non_price_2_value}=            percents                        ${item_non_price_2_value}
    ${item_non_price_2_value}=            convert to string               ${item_non_price_2_value}
    ${item_non_price_2_title}=            Get From Dictionary             ${features[2].enum[1]}                      title
    ${item_non_price_3_value}=            convert to number               ${features[2].enum[2].value}
    ${item_non_price_3_value}=            percents                        ${item_non_price_3_value}
    ${item_non_price_3_value}=            convert to string               ${item_non_price_3_value}=
    ${item_non_price_3_title}=            Get From Dictionary             ${features[2].enum[2]}                      title
    #Контактна особа
	${contact_point_name}=                Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    name
	${contact_point_name_en}=             Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    name_en
	${contact_point_name_en}=             Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    name_en
	${contact_point_phone}=               Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    telephone
	${contact_point_fax}=                 Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    faxNumber
	${contact_point_email}=               Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    email
	${owner_legal_name_en}=               Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.identifier}      legalName_en
	${owner_legal_name_en_str}=           convert to string               ${owner_legal_name_en}
    ${owner_name_en}=                     Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity}                 name_en
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
    click element  id=procurementMethodType
    sleep  2
    click element  xpath=//div [@class='md-select-menu-container md-active md-clickable']//md-select-menu [@class = '_md']//md-content [@class = '_md']//md-option[3]
    input text  ${Поле "Узагальнена назва закупівлі"}  ${title}
    sleep  2
    input text  id=title-en                            ${title_en}
    focus  id=tender-value-vat
    sleep  2
    run keyword if       '${vat}'     click element      id=tender-value-vat
    sleep  1
    input text  id=description     ${description}
    sleep  1
    input text  id=description_en  ${description_en}
    #Заповнюємо дати
    sleep  2
    input text  xpath=(.//input[@class='md-datepicker-input'])[1]                       ${tenderPeriod_endDate_str}
    sleep  3
    input text   xpath=(//*[@id="timeInput"])[1]                                        ${tenderPeriod_endDate_time}
    sleep  3
    #Переходимо на вкладку "Лоти закупівлі"
    execute javascript  angular.element("md-tab-item")[1].click()
    sleep  2
    wait until element is visible  ${Поле "Узагальнена назва лоту"}  30
    input text      ${Поле "Узагальнена назва лоту"}                                    ${lot_title}
    input text      id=lotTitleEn.0                                                     ${lot_title_en}
    #заповнюємо поле "Очікувана вартість закупівлі"
#    input text      amount-lot-value.0                                                  ${lot_amount_str}
    input text      amount-lot-value.0                                                  ${lot_amount}
    sleep  1
    #Заповнюємо поле "Примітки"
    input text      lotDescription-0                                                    ${lot_description}
    #Заповнюємо поле "Мінімальний крок пониження ціни"
    input text      amount-lot-minimalStep.0                                            ${lot_minimal_step_amount_str}
    #переходимо на вкладку "Специфікації закупівлі"
    Execute Javascript  $($("app-tender-lot")).find("md-tab-item")[1].click()
    wait until element is visible  ${Поле "Конкретна назва предмета закупівлі"}  30
    input text      ${Поле "Конкретна назва предмета закупівлі"}                        ${item_description}
    input text      id=itemDescription_en--                                             ${item_description_en}
    input text      id=itemQuantity--                                                   ${item_quantity}
    #Заповнюємо поле "Код ДК 021-2015 "
    Execute Javascript    $($('[id=cpv]')[0]).scope().value.classification = {id: "${item_id}", description: "${item_descr}", scheme: "${item_scheme}"};
    sleep  2
    #Заповнюємо додаткові коди
    run keyword and ignore error  Заповнюємо додаткові коди
    sleep  2
    #Заповнюємо поле "Одиниці виміру"
    Select From List  id=unit-unit--  ${item_unit}
    #Заповнюємо датапікери
    input text      xpath=(*//input[@class='md-datepicker-input'])[2]                   ${delivery_StartDate_str}
    sleep  2
    input text      xpath=(//*[@id="timeInput"])[2]                                     ${delivery_StartDate_time}
    sleep  2
    input text      xpath=(.//input[@class='md-datepicker-input'])[3]                   ${delivery_endDate_str}
    sleep  2
    input text      xpath=(//*[@id="timeInput"])[3]                                     ${delivery_endDate_time}
    sleep  2
    #Заповнюємо адресу доставки
    select from list  id=countryName.value.deliveryAddress--                            ${item_countryName}
    input text        id=streetAddress.value.deliveryAddress--                          ${item_streetAddress}
    input text        id=locality.value.deliveryAddress--                               ${item_locality}
    input text        id=region.value.deliveryAddress--                                 ${item_region}
    input text        id=postalCode.value.deliveryAddress--                             ${item_postalCode}
    sleep  2

    #Переходимо на вкладку "Інші крітерії оцінки"
    Execute Javascript          angular.element("md-tab-item")[2].click()
    sleep  3
    #заповнюємо нецінові крітерії лоту
    click element               featureAddAction
    sleep  1
    input text                  xpath=(//*[@id="feature.title."])[1]                    ${lot_features_title}
    input text                  xpath=(//*[@id="feature.description."])[1]              ${lot_features_description}
    select from list by value   xpath=(//*[@id="feature.featureOf."])[1]                ${lot_features_of}
    sleep  2
    select from list by label   xpath=//*[@id="feature.relatedItem."][1]                ${lot_title}
    sleep  2
    click element               xpath=(//*[@id="enumAddAction"])[1]
    sleep  1
    input text                  enum.title.0.0                                          ${lot_non_price_1_title}
    input text                  enum.value.0.0                                          ${lot_non_price_1_value}
    click element               xpath=(//*[@id="enumAddAction"])[1]
    sleep  1
    input text                  enum.title.0.1                                          ${lot_non_price_2_title}
    input text                  enum.value.0.1                                          ${lot_non_price_2_value}
    click element               xpath=(//*[@id="enumAddAction"])[1]
    sleep  1
    input text                  enum.title.0.2                                          ${lot_non_price_3_title}
    input text                  enum.value.0.2                                          ${lot_non_price_3_value}

    Execute Javascript    angular.element("md-tab-item")[3].click()
    sleep  3
    Execute Javascript    angular.element("md-tab-item")[2].click()
    sleep  3

    #заповнюємо нецінові крітерії тендеру
    click element               featureAddAction
    sleep  1
    input text                  xpath=(//*[@id="feature.title."])[2]                    ${tender_features_title}
    input text                  xpath=(//*[@id="feature.description."])[2]              ${tender_features_description}
    select from list by value   xpath=(//*[@id="feature.featureOf."])[2]                ${tender_features_of}
    sleep  2
    click element               xpath=(//*[@id="enumAddAction"])[2]
    sleep  1
    input text                  enum.title.1.0                                          ${tender_non_price_1_title}
    input text                  enum.value.1.0                                          ${tender_non_price_1_value}
    click element               xpath=(//*[@id="enumAddAction"])[2]
    sleep  1
    input text                  enum.title.1.1                                          ${tender_non_price_2_title}
    input text                  enum.value.1.1                                          ${tender_non_price_2_value}
    click element               xpath=(//*[@id="enumAddAction"])[2]
    sleep  1
    input text                  enum.title.1.2                                          ${tender_non_price_3_title}
    input text                  enum.value.1.2                                          ${tender_non_price_3_value}
    Execute Javascript    angular.element("md-tab-item")[3].click()
    sleep  3
    Execute Javascript    angular.element("md-tab-item")[2].click()
    sleep  3
    #заповнюємо нецінові крітерії айтему
    click element               featureAddAction
    sleep  1
    input text                  xpath=(//*[@id="feature.title."])[3]                    ${item_features_title}
    input text                  xpath=(//*[@id="feature.description."])[3]              ${item_features_description}
    select from list by value   xpath=(//*[@id="feature.featureOf."])[3]                ${item_features_of}
    sleep  3
    select from list by label   xpath=(//*[@id="feature.relatedItem."])[2]                ${item_description}
    sleep  3
    click element               xpath=(//*[@id="enumAddAction"])[3]
    sleep  1
    input text                  enum.title.2.0                                          ${item_non_price_1_title}
    input text                  enum.value.2.0                                          ${item_non_price_1_value}
    click element               xpath=(//*[@id="enumAddAction"])[3]
    sleep  1
    input text                  enum.title.2.1                                          ${item_non_price_2_title}
    input text                  enum.value.2.1                                          ${item_non_price_2_value}
    click element               xpath=(//*[@id="enumAddAction"])[3]
    sleep  1
    input text                  enum.title.2.2                                          ${item_non_price_3_title}
    input text                  enum.value.2.2                                          ${item_non_price_3_value}
    # Переходимо на вкладку "Контактна особа"
    Execute Javascript    angular.element("md-tab-item")[3].click()
    sleep  3
    input text            procuringEntityContactPointName                               ${contact_point_name}
    input text            procuringEntityContactPointTelephone                          ${contact_point_phone}
    input text            procuringEntityContactPointFax                                ${contact_point_fax}
    input text            procuringEntityContactPointEmail                              ${contact_point_email}
    input text            procuringEntityContactPointNameEn                             ${contact_point_name_en}
    input text            procuringEntityNameEn                                         ${owner_name_en}
    input text            procuringEntityIdentifierLegalNameEn                          ${owner_legal_name_en}
    input text            procurementMethodDetails                                      ${acceleration_mode}
#    input text            submissionMethodDetails                                       quick(mode:fast-forward)
    input text            mode                                                          test
    sleep  3
    click button  tender-apply
    sleep  3
    ${NewTenderUrl}=  Execute Javascript  return window.location.href
    SET GLOBAL VARIABLE          ${NewTenderUrl}
    sleep  4
    wait until element is visible  ${Поле "Узагальнена назва закупівлі"}  30
    click button                   ${Кнопка "Опублікувати"}
    wait until element is visible  ${Кнопка "Так" у попап вікні}  60
    click element                  ${Кнопка "Так" у попап вікні}
    #Очікуємо появи повідомлення
    wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
    sleep  5
    ${localID}=    get_local_id_from_url        ${NewTenderUrl}
#    ${hrefToTender}=    Evaluate    "/etm-Qa_fe/dashboard/tender-drafts/" + str(${localID})

    ${hrefToTender}=    Evaluate    "/dashboard/tender-drafts/" + str(${localID})

    Wait Until Page Contains Element    xpath=//a[@href="${hrefToTender}"]    30
    Go to  ${NewTenderUrl}
	Wait Until Page Contains Element  id=tenderUID    100
	Wait Until Page Contains Element  id=tenderID     100
    ${tender_id}=  Get Text  xpath=//a[@id='tenderUID']
    ${TENDER_UA}=  Get Text  id=tenderID
    set global variable  ${TENDER_UA}
    ${ViewTenderUrl}=  assemble_viewtender_url  ${NewTenderUrl}  ${tender_id}
	SET GLOBAL VARIABLE                         ${ViewTenderUrl}
	log to console  ${ViewTenderUrl}
    log to console  закінчили "Створити тендер aboveThresholdEU"

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
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${TENDER}
  run keyword if  '${TENDER_TYPE}' == 'negotiation'         Завантажити документ процедури negotiation        @{ARGUMENTS}
  run keyword if  '${TENDER_TYPE}' == 'aboveThresholdEU'    Завантажити документ процедури aboveThresholdEU   @{ARGUMENTS}
  run keyword if  '${TENDER_TYPE}' == 'aboveThresholdUA'    Завантажити документ процедури aboveThresholdEU   @{ARGUMENTS}

Завантажити документ процедури negotiation
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
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

Завантажити документ процедури aboveThresholdEU
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${TENDER}
  Go to               ${NewTenderUrl}
  sleep  10
  # Нажатие на кнопку "Тендерна документація/нецінові критерії закупівлі"
  Execute Javascript    $(angular.element("md-tab-item")[2]).click()
  # +Додати
  wait until page contains element  id=tenderDocumentAddAction    10
  Click Button    id=tenderDocumentAddAction
  #Вибір тендерної документації з переліка
  Execute Javascript    $("#type-tender-documents-0").val("biddingDocuments");
  Choose file     id=file-tender-documents-0    ${ARGUMENTS[1]}
  # Кнопка "Застосувати"
  sleep    3s
  Execute Javascript    $("#tender-apply").click()
  # Кнопка "Опублікувати"
  Page should contain element      id=tender-publish
  Wait Until Element Is Enabled    id=tender-publish
  Click Button    id=tender-publish
  # Кнопка "Так"
  Wait Until Page Contains Element    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]    20
  Click Button    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  3


















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
  #натискаємо кнопку пошук (для сценарію complaints, aboveThresholdEU, aboveThresholdUA)
  run keyword if  '${TENDER_TYPE}' == 'complaints'        click element  xpath=(.//span[@class='ng-binding ng-scope'])[2]
  run keyword if  '${TENDER_TYPE}' == 'aboveThresholdEU'  click element  xpath=(.//span[@class='ng-binding ng-scope'])[2]
  run keyword if  '${TENDER_TYPE}' == 'aboveThresholdUA'  click element  xpath=(.//span[@class='ng-binding ng-scope'])[2]
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
  run keyword if  '${TENDER_TYPE}' == 'complaints'        Отримати інформацію із тендера для скарг                    @{ARGUMENTS}
  run keyword if  '${TENDER_TYPE}' == 'negotiation'       Отримати інформацію із тендера для переговорної процедури   @{ARGUMENTS}
  run keyword if  '${TENDER_TYPE}' == 'aboveThresholdEU'  Отримати інформацію із тендера для openEU                   @{ARGUMENTS}
  run keyword if  '${TENDER_TYPE}' == 'aboveThresholdUA'  Отримати інформацію із тендера для openEU                   @{ARGUMENTS}
  [return]  ${return_value}


Отримати інформацію із тендера для openEU
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${field}
  ${return_value}=  run keyword  Отримати інформацію про тендер ${ARGUMENTS[2]}
  set global variable  ${return_value}

Отримати інформацію із тендера для переговорної процедури
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${field}
  ${return_value}=  run keyword  Отримати інформацію про переговорний ${ARGUMENTS[2]}
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

Отримати інформацію про переговорний title
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

Отримати інформацію про переговорний tenderId
#Відображення ідентифікатора переговорної процедури
    wait until element is visible  id=tenderID  20
    ${return_value}=    Get Text   id=tenderID
    [return]    ${return_value}

Отримати інформацію про переговорний description
#Відображення опису переговорної процедури
    wait until element is visible  xpath=.//*[@dataanchor='tenderView']//*[@dataanchor='description']  20
	${return_value}=    Get Text   xpath=.//*[@dataanchor='tenderView']//*[@dataanchor='description']
    [return]  ${return_value}

Отримати інформацію про переговорний causeDescription
#Відображення підстави вибору переговорної процедури
    wait until element is visible  id=causeDescription  20
	${return_value}=    Get Text   id=causeDescription
    [return]  ${return_value}

Отримати інформацію про переговорний cause
#Відображення обгрунтування причини вибору переговорної процедури
    wait until element is visible  id=cause  20
	${return_value}=    get value  id=cause
    [return]  ${return_value}

Отримати інформацію про переговорний value.amount
#Відображення бюджету переговорної процедури
    wait until element is visible  xpath=(.//*[@dataanchor='value'])[1]  20
	${return_value}=     Get Text  xpath=(.//*[@dataanchor='value'])[1]
	log to console  *
	log to console  Get Text ${return_value}
	${return_value}=    get_numberic_part    ${return_value}
	log to console  get_numberic_part ${return_value}
#	${return_value}=    Convert To Number    ${return_value}
	${return_value}=    adapt_numbers2    ${return_value}
	log to console  adapt_numbers2  ${return_value}
#	${return_value}=    adapt_numbers    ${return_value}
    [return]  ${return_value}

Отримати інформацію про переговорний value.currency
#Відображення валюти переговорної процедури
    wait until element is visible  xpath=.//*[@dataanchor='value.currency']  20
	${return_value}=     Get Text  xpath=.//*[@dataanchor='value.currency']
    [return]  ${return_value}

Отримати інформацію про переговорний value.valueAddedTaxIncluded
#Відображення врахованого податку в бюджет переговорної процедури
    wait until element is visible  xpath=.//*[@dataanchor='tenderView']//*[@dataanchor='value.valueAddedTaxIncluded']  20
    ${tax}=              Get Text  xpath=.//*[@dataanchor='tenderView']//*[@dataanchor='value.valueAddedTaxIncluded']
    ${return_value}=    tax adapt  ${tax}
    [return]  ${return_value}

Отримати інформацію про переговорний procuringEntity.address.countryName
#Відображення країни замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='sub-text-block']/div)[2]
    ${temp_value} =      get text  xpath=(.//div[@class='sub-text-block']/div)[2]
    ${value}=  convert to integer  1
    ${return_value}=  parse_address_for_viewer  ${temp_value}  ${value}
    [return]  ${return_value}

Отримати інформацію про переговорний procuringEntity.address.locality
#Відображення населеного пункту замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='sub-text-block']/div)[2]  20
    ${temp_value} =      get text  xpath=(.//div[@class='sub-text-block']/div)[2]
    ${value}=  convert to integer  3
    ${return_value}=  parse_address_for_viewer  ${temp_value}  ${value}
    [return]  ${return_value}

Отримати інформацію про переговорний procuringEntity.address.postalCode
#Відображення поштового коду замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='sub-text-block']/div)[2]  20
    ${temp_value} =      get text  xpath=(.//div[@class='sub-text-block']/div)[2]
    ${value}=  convert to integer  0
    ${return_value}=  parse_address_for_viewer  ${temp_value}  ${value}
    [return]  ${return_value}

Отримати інформацію про переговорний procuringEntity.address.region
#Відображення області замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='sub-text-block']/div)[2]  20
    ${temp_value} =      get text  xpath=(.//div[@class='sub-text-block']/div)[2]
    ${value}=  convert to integer  2
    ${return_value}=  parse_address_for_viewer  ${temp_value}  ${value}
    [return]  ${return_value}

Отримати інформацію про переговорний procuringEntity.address.streetAddress
#Відображення вулиці замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='sub-text-block']/div)[2]  20
    ${temp_value} =      get text  xpath=(.//div[@class='sub-text-block']/div)[2]
    ${value}=  convert to integer  4
    ${return_value}=  parse_address_for_viewer  ${temp_value}  ${value}
    [return]  ${return_value}

Отримати інформацію про переговорний procuringEntity.contactPoint.name
#Відображення контактного імені замовника переговорної процедури
    wait until element is visible  xpath=.//div[@class='field-value ng-binding flex']  20
	${return_value}=     Get Text  xpath=.//div[@class='field-value ng-binding flex']
    [return]  ${return_value}

Отримати інформацію про переговорний procuringEntity.contactPoint.telephone
#Відображення контактного телефону замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='field-value flex'])[1]  20
	${return_value}=     Get Text  xpath=(.//div[@class='field-value flex'])[1]
    [return]  ${return_value}

Отримати інформацію про переговорний procuringEntity.contactPoint.url
#Відображення сайту замовника переговорної процедури
    wait until element is visible  xpath=.//div[@class='horisontal-centering']  20
	${return_value}=     Get Text  xpath=.//div[@class='horisontal-centering']
    [return]  ${return_value}

Отримати інформацію про переговорний procuringEntity.identifier.legalName
#Відображення офіційного імені замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='sub-text-block'])[1]  20
	${return_value}=     Get Text  xpath=(.//div[@class='sub-text-block'])[1]
    [return]  ${return_value}

Отримати інформацію про переговорний procuringEntity.identifier.id
#Відображення ідентифікатора замовника переговорної процедури
    wait until element is visible  xpath=(.//div[@class='horisontal-centering ng-binding'])[2]  20
	${return_value}=     Get Text  xpath=(.//div[@class='horisontal-centering ng-binding'])[2]
    [return]  ${return_value}

Отримати інформацію про переговорний procuringEntity.name
#Відображення імені замовника переговорної процедури
    wait until element is visible  xpath=.//div[@class='align-text-at-center flex-none']  20
	${return_value}=     Get Text  xpath=.//div[@class='align-text-at-center flex-none']
    [return]  ${return_value}

Отримати інформацію про переговорний documents[0].title
    wait until element is visible  xpath=(.//button[@tender-id])[1]  20
    click element                  xpath=(.//button[@tender-id])[1]
    sleep  3
	${return_value}=  Get Text     xpath=.//div[@class='document-title-label']
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].documents[0].title
    wait until element is visible  xpath=(.//button[@tender-id])[2]  20
    click element                  xpath=(.//button[@tender-id])[2]
    sleep  3
	${return_value}=  Get Text     xpath=.//div[@class='document-title-label']
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].status
    wait until element is visible  xpath=(.//td[@class='ng-binding'])[3]  20
	${return_value}=  Get Text     xpath=(.//td[@class='ng-binding'])[3]
    ${return_value}=  participant status  ${return_value}
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].suppliers[0].address.countryName
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[3]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[3]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].suppliers[0].address.locality
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[4]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[4]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].suppliers[0].address.postalCode
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[5]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[5]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].suppliers[0].address.region
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[6]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[6]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].suppliers[0].address.streetAddress
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[7]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[7]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про переговорний procuringEntity.identifier.scheme
#Відображення схеми ідентифікації замовника переговорної процедури
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=.//div[@id='OwnerScheme']  20
    ${return_value}=  get element attribute  xpath=.//div[@id='OwnerScheme']@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].suppliers[0].contactPoint.telephone
    click element  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//a[@rel='nofollow'])[5]  20
    ${return_value}=  get element attribute  xpath=(.//a[@rel='nofollow'])[5]@textContent
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].suppliers[0].contactPoint.name
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[2]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[2]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].suppliers[0].contactPoint.email
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//a[@rel='nofollow'])[7]  20
    ${return_value}=  get element attribute  xpath=(.//a[@rel='nofollow'])[7]@textContent
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].suppliers[0].identifier.scheme
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[8]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[8]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].suppliers[0].identifier.legalName
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex'])[9]  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex'])[9]@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].suppliers[0].identifier.id
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=(.//div[@class='field-value ng-binding flex-20'])  20
    ${return_value}=  get element attribute  xpath=(.//div[@class='field-value ng-binding flex-20'])@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].suppliers[0].name
    click element                  xpath=(.//div[@class='horisontal-centering ng-binding'])[11]
    wait until element is visible  xpath=.//div[@class='horisontal-centering ng-binding flex']  20
    ${return_value}=  get element attribute  xpath=.//div[@class='horisontal-centering ng-binding flex']@textContent
    ${return_value}=  trim data  ${return_value}
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].value.valueAddedTaxIncluded
    wait until element is visible  xpath=(.//span[@dataanchor='value.valueAddedTaxIncluded'])[2]  20
    ${value}=  get text            xpath=(.//span[@dataanchor='value.valueAddedTaxIncluded'])[2]
    ${return_value}=  tax_adapt  ${value}
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].value.currency
    wait until element is visible  xpath=(.//span[@dataanchor='value.currency'])[2]  20
    ${return_value}=     get text  xpath=(.//span[@dataanchor='value.currency'])[2]
    [return]  ${return_value}

Отримати інформацію про переговорний awards[0].value.amount
    wait until element is visible  xpath=.//span[@dataanchor='value.amount']  20
    ${value}=            get text  xpath=.//span[@dataanchor='value.amount']
    ${return_value}=  convert to integer  ${value}
    [return]  ${return_value}

Отримати інформацію про переговорний contracts[0].status
    wait until element is visible  xpath=.//span[@id='contract-status']  20
	${return_value}=  get value  xpath=.//span[@id='contract-status']
    [return]  ${return_value}

Отримати інформацію із предмету
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...      ${ARGUMENTS[0]} ==  ${username}
    ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
    ...      ${ARGUMENTS[2]} ==  ${object_id}
    ...      ${ARGUMENTS[3]} ==  ${field_name}
    run keyword if  '${TENDER_TYPE}' == 'negotiation'       Отримати інформацію із предмета для переговорної процедури   @{ARGUMENTS}
    run keyword if  '${TENDER_TYPE}' == 'aboveThresholdEU'  Отримати інформацію із предмета для openEU                   @{ARGUMENTS}
    run keyword if  '${TENDER_TYPE}' == 'aboveThresholdUA'  Отримати інформацію із предмета для openEU                   @{ARGUMENTS}
    [return]  ${return_value}

Отримати інформацію із предмета для переговорної процедури
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...      ${ARGUMENTS[0]} ==  ${username}
    ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
    ...      ${ARGUMENTS[2]} ==  ${object_id}
    ...      ${ARGUMENTS[3]} ==  ${field_name}
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

Отримати інформацію із предмета для openEU
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${object_id}
  ...      ${ARGUMENTS[3]} ==  ${field_name}
  go to  ${ViewTenderUrl}
  sleep  10
  run keyword if  '${ARGUMENTS[3]}' == 'description'                     Отримати інформацію про предмет description   @{ARGUMENTS}
  run keyword if  '${ARGUMENTS[3]}' == 'deliveryDate.startDate'          Отримати інформацію про предмет deliveryDate.startDate
  run keyword if  '${ARGUMENTS[3]}' == 'deliveryDate.endDate'            Отримати інформацію про предмет deliveryDate.endDate
  run keyword if  '${ARGUMENTS[3]}' == 'deliveryAddress.countryName'     Отримати інформацію про предмет deliveryAddress.countryName
  run keyword if  '${ARGUMENTS[3]}' == 'deliveryAddress.postalCode'      Отримати інформацію про предмет deliveryAddress.postalCode
  run keyword if  '${ARGUMENTS[3]}' == 'deliveryAddress.region'          Отримати інформацію про предмет deliveryAddress.region
  run keyword if  '${ARGUMENTS[3]}' == 'deliveryAddress.locality'        Отримати інформацію про предмет deliveryAddress.locality
  run keyword if  '${ARGUMENTS[3]}' == 'deliveryAddress.streetAddress'   Отримати інформацію про предмет deliveryAddress.streetAddress
  run keyword if  '${ARGUMENTS[3]}' == 'classification.scheme'           Отримати інформацію про предмет classification.scheme
  run keyword if  '${ARGUMENTS[3]}' == 'classification.id'               Отримати інформацію про предмет classification.id
  run keyword if  '${ARGUMENTS[3]}' == 'classification.description'      Отримати інформацію про предмет classification.description
  run keyword if  '${ARGUMENTS[3]}' == 'unit.name'                       Отримати інформацію про предмет unit.name
  run keyword if  '${ARGUMENTS[3]}' == 'unit.code'                       Отримати інформацію про предмет unit.code
  run keyword if  '${ARGUMENTS[3]}' == 'quantity'                        Отримати інформацію про предмет quantity
  run keyword if  '${ARGUMENTS[3]}' == 'deliveryLocation.latitude'       Отримати інформацію про предмет deliveryLocation.latitude
  run keyword if  '${ARGUMENTS[3]}' == 'deliveryLocation.longitude'      Отримати інформацію про предмет deliveryLocation.longitude

Отримати інформацію про items[0].description
#Відображення опису номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@convert-line-break])[1]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[1].description
#Відображення опису номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@convert-line-break])[2]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].description
#Відображення опису основної/додаткової класифікації номенклатур пе
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='description'])[2]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[1].additionalClassifications[0].description
#Відображення опису основної/додаткової класифікації номенклатур пе
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='description'])[4]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].id
#Відображення ідентифікатора основної/додаткової класифікації номен
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='value'])[2]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[1].additionalClassifications[0].id
#Відображення ідентифікатора основної/додаткової класифікації номен
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='value'])[4]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].scheme
#Відображення схеми основної/додаткової класифікації номенклатур пе
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='scheme'])[2]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[1].additionalClassifications[0].scheme
#Відображення схеми основної/додаткової класифікації номенклатур пе
    sleep  5
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='scheme'])[4]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[0].classification.scheme
    sleep  5
#Відображення схеми основної/додаткової класифікації номенклатур пе
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='scheme'])[1]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[1].classification.scheme
#Відображення схеми основної/додаткової класифікації номенклатур пе
    sleep  10
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='scheme'])[${count}]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[0].classification.id
#Відображення ідентифікатора основної/додаткової класифікації номен
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='value'])[1]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[1].classification.id
#Відображення ідентифікатора основної/додаткової класифікації номен
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='value'])[${count}]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[0].classification.description
#ідображення опису основної/додаткової класифікації номенклатур пе
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='description'])[1]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[1].classification.description
#ідображення опису основної/додаткової класифікації номенклатур пе
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='description'])[${count}]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[0].quantity
#Відображення кількості номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity'])[1]@textContent
    ${return_value}=  convert to integer  ${return_value}
    set global variable  ${return_value}

Отримати інформацію про items[1].quantity
#Відображення кількості номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity'])[2]@textContent
    ${return_value}=  convert to integer  ${return_value}
    set global variable  ${return_value}

Отримати інформацію про items[0].unit.name
#Відображення назви одиниці номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity.unit.name'])[1]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[1].unit.name
#Відображення назви одиниці номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity.unit.name'])[1]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[0].unit.code
#ідображення коду одиниці номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity.unit.code'])[1]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[1].unit.code
#ідображення коду одиниці номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity.unit.code'])[2]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[0].deliveryDate.endDate
#Відображення дати доставки номенклатури переговорної процедури
    ${return_value}=  get value  xpath=(.//span[@dataanchor='deliveryDate.endDate'])[1]
    set global variable  ${return_value}

Отримати інформацію про items[1].deliveryDate.endDate
#Відображення дати доставки номенклатури переговорної процедури
    ${return_value}=  get value  xpath=(.//span[@dataanchor='deliveryDate.endDate'])[2]
    set global variable  ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName
#Відображення назви країни доставки номенклатури переговорної проце
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='countryName'])[1]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[1].deliveryAddress.countryName
#Відображення назви країни доставки номенклатури переговорної проце
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='countryName'])[2]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[0].deliveryAddress.postalCode
#Відображення пошт. коду доставки номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='postalCode'])[1]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[1].deliveryAddress.postalCode
#Відображення пошт. коду доставки номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='postalCode'])[2]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[0].deliveryAddress.region
#Відображення регіону доставки номенклатури переговорної процедури
    sleep  5
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='region'])[1]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[1].deliveryAddress.region
#Відображення регіону доставки номенклатури переговорної процедури
    sleep  5
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='region'])[2]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[0].deliveryAddress.locality
#Відображення населеного пункту адреси доставки номенклатури перего
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='locality'])[1]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[1].deliveryAddress.locality
#Відображення населеного пункту адреси доставки номенклатури перего
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='locality'])[2]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[0].deliveryAddress.streetAddress
#Відображення вулиці доставки номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='streetAddress'])[1]@textContent
    set global variable  ${return_value}

Отримати інформацію про items[1].deliveryAddress.streetAddress
#Відображення вулиці доставки номенклатури переговорної процедури
    ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='streetAddress'])[2]@textContent
    set global variable  ${return_value}

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
  log to console  *
  log to console  починаємо "Отримати інформацію із лоту"
  run keyword if  '${TENDER_TYPE}' == 'complaints'        Отримати інформацію із лоту для скарг      @{ARGUMENTS}
  run keyword if  '${TENDER_TYPE}' == 'aboveThresholdEU'  Отримати інформацію із лоту для openEU     @{ARGUMENTS}
  run keyword if  '${TENDER_TYPE}' == 'aboveThresholdUA'  Отримати інформацію із лоту для openEU     @{ARGUMENTS}
  [return]  ${return_value}

Отримати інформацію із лоту для скарг
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${object_id}
  ...      ${ARGUMENTS[3]} ==  ${field_name}
  go to  ${ViewTenderUrl}
  sleep  10
  ${return_value}=  get text  xpath=(.//div[@class='field-value word-break ng-binding flex-70'])[1]
  set global variable  ${return_value}

Отримати інформацію із лоту для openEU
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${object_id}
  ...      ${ARGUMENTS[3]} ==  ${field_name}
  go to  ${ViewTenderUrl}
  sleep  10
  log to console  *
  log to console  починаємо "Отримати інформацію із лоту для openEU "
  run keyword if  '${ARGUMENTS[3]}' == 'title'                                  Отримати інформацію про лот title                  @{ARGUMENTS}
  run keyword if  '${ARGUMENTS[3]}' == 'value.amount'                           Отримати інформацію про лот value.amount
  run keyword if  '${ARGUMENTS[3]}' == 'minimalStep.amount'                     Отримати інформацію про лот minimalStep.amount
  run keyword if  '${ARGUMENTS[3]}' == 'description'                            Отримати інформацію про лот description
  run keyword if  '${ARGUMENTS[3]}' == 'value.currency'                         Отримати інформацію про лот value.currency
  run keyword if  '${ARGUMENTS[3]}' == 'value.valueAddedTaxIncluded'            Отримати інформацію про лот value.valueAddedTaxIncluded
  run keyword if  '${ARGUMENTS[3]}' == 'minimalStep.currency'                   Отримати інформацію про лот minimalStep.currency
  run keyword if  '${ARGUMENTS[3]}' == 'minimalStep.valueAddedTaxIncluded'      Отримати інформацію про лот minimalStep.valueAddedTaxIncluded


#Отримати інформацію про тендер lots[0].value.amount
##Відображення бюджету лотів
#  log to console  *
#  ${return_value}=          get text                xpath=.//span[@dataanchor='amount']
#  log to console  get text  ${return_value}
#  ${return_value}=          get_numberic_part       ${return_value}
#  log to console  get_numberic_part  ${return_value}
#  ${return_value}=    adapt_numbers2   ${return_value}
#  log to console  adapt_numbers2  ${return_value}
#  [return]  ${return_value}

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

  run keyword if  '${TENDER_TYPE}' == 'complaints'                  Подати цінову пропозицію complaints         @{ARGUMENTS}
  run keyword if  '${TENDER_TYPE}' == 'aboveThresholdEU'            Подати цінову пропозицію aboveThresholdEU   @{ARGUMENTS}
  run keyword if  '${TENDER_TYPE}' == 'aboveThresholdUA'            Подати цінову пропозицію aboveThresholdEU   @{ARGUMENTS}

Подати цінову пропозицію complaints
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

Подати цінову пропозицію aboveThresholdEU
#Можливість подати пропозицію першим учасником
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  ${username}
    ...    ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
    ...    ${ARGUMENTS[2]} ==  ${bid}
    ...    ${ARGUMENTS[3]} ==  ${lots_ids}
    ...    ${ARGUMENTS[4]} ==  ${features_ids}
    ${lot} =  convert to string  ${ARGUMENTS[3]}
    ${feature}=  convert to string  ${ARGUMENTS[4][0]}
    ${bid_amount}=        adapt_numbers            ${ARGUMENTS[2].data.lotValues[0].value.amount}
    ${bid_amount_str}=    convert to string        ${bid_amount}
    go to  ${ViewTenderUrl}
    wait until element is visible  xpath=.//span[@ng-if='data.status']  60
    sleep  5
    #Кнопка "Додати пропозицію"
    execute javascript             angular.element("#set-participate-in-lot").click()
    sleep  3
    input text                     id=lot-amount-0       ${bid_amount_str}
    sleep  3
    click element  id=bid-selfQualified
    sleep  2
    click element  id=bid-selfEligible
    sleep  2
    #Кнопка "Відправити пропозиції"
    execute javascript             angular.element("#tender-update-bid").click()
    wait until element is visible  xpath=.//button[@ng-click='ok()']  60
    click element                  xpath=.//button[@ng-click='ok()']
    sleep  10

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

Отримати інформацію про тендер value.amount
  #Відображення бюджету тендера
  ${return_value}=    Get Text    xpath=(.//*[@dataanchor='value'])[1]
  ${return_value}=    get_numberic_part    ${return_value}
  ${return_value}=    adapt_numbers2   ${return_value}
  [return]  ${return_value}

Отримати інформацію про тендер enquiryPeriod.startDate
#Відображення початку періоду уточнення тендера
  ${return_value}=    Execute Javascript    return angular.element(document.querySelectorAll("[dataanchor='tenderView']")[0]).scope().data.enquiryPeriod.startDate
  [return]    ${return_value}

Отримати інформацію про тендер enquiryPeriod.endDate
#Відображення закінчення періоду уточнення тендера
    ${return_value}=    Execute Javascript    return angular.element(document.querySelectorAll("[dataanchor='tenderView']")[0]).scope().data.enquiryPeriod.endDate
	[return]    ${return_value}

Отримати інформацію про тендер tenderPeriod.startDate
#Відображення початку періоду прийому пропозицій тендер
    ${return_value}=    Execute Javascript    return angular.element(document.querySelectorAll("[dataanchor='tenderView']")[0]).scope().data.tenderPeriod.startDate
    [return]    ${return_value}

Отримати інформацію про тендер tenderPeriod.endDate
#Відображення закінчення періоду прийому пропозицій тендера
    ${return_value}=    Execute Javascript    return angular.element(document.querySelectorAll("[dataanchor='tenderView']")[0]).scope().data.tenderPeriod.endDate
    ${doc_counter}=  convert to integer  0
    set global variable  ${doc_counter}
    [return]    ${return_value}

Отримати інформацію про тендер complaintPeriod.endDate
#Відображення закінчення періоду подання скарг на оголошений тендер
  ${return_value}=    Execute Javascript      return angular.element("#robotStatus").scope().data.complaintPeriod.endDate
  [return]  ${return_value}

Отримати інформацію про тендер procurementMethodType
#Відображення типу оголошеного тендера
  ${return_value}=    Execute Javascript      return angular.element("#robotStatus").scope().tenderInitialState.procurementMethodType
  [return]  ${return_value}

Отримати інформацію про тендер status
  ${return_value}=    get element attribute  xpath=//*[@id="robotStatus"]@textContent
  [return]  ${return_value}

Отримати інформацію про тендер qualifications[0].status
  ${return_value}=    get element attribute  xpath=(.//td[@class='ng-binding'])[2]@textContent
  ${return_value}=    get_proposition_status  ${return_value}
  [return]  ${return_value}

Отримати інформацію про тендер qualifications[1].status
  ${return_value}=    get element attribute  xpath=(.//td[@class='ng-binding'])[4]@textContent
  ${return_value}=    get_proposition_status  ${return_value}
  [return]  ${return_value}

Отримати інформацію про тендер questions[0].title
  ${return_value}=    get element attribute  xpath=.//span[@dataanchor='title']@textContent
  [return]  ${return_value}


Отримати інформацію про тендер qualificationPeriod.endDate
#Відображення дати закінчення періоду блокування перед початком аук
  ${return_value}=    get value              xpath=.//span[@id='qualification-end-date']
  [return]  ${return_value}

Отримати інформацію про предмет description
#Відображення опису номенклатур тендера
  [Arguments]  @{ARGUMENTS}
  ${return_value}=    Execute Javascript      return _.find(angular.element("#robotStatus").scope().data.items, function(item){return item.description.indexOf('${ARGUMENTS[2]}')> -1}).description
  set global variable  ${return_value}

Отримати інформацію про предмет deliveryDate.startDate
#Відображення дати початку доставки номенклатур тендера
  ${return_value}=    Execute Javascript    return angular.element(document.querySelectorAll("[dataanchor='tenderView']")[0].querySelectorAll("[dataanchor='lots']")[0].querySelectorAll("[dataanchor='lot']")[0].querySelectorAll("[dataanchor='specifications']")[0].querySelectorAll("[dataanchor='specification']")[0]).scope().lotItem.items[0].deliveryDate.startDate
  set global variable  ${return_value}

Отримати інформацію про предмет deliveryDate.endDate
#Відображення дати кінця доставки номенклатур тендера
  ${return_value}=    Execute Javascript    return angular.element(document.querySelectorAll("[dataanchor='tenderView']")[0].querySelectorAll("[dataanchor='lots']")[0].querySelectorAll("[dataanchor='lot']")[0].querySelectorAll("[dataanchor='specifications']")[0].querySelectorAll("[dataanchor='specification']")[0]).scope().lotItem.items[0].deliveryDate.endDate
  set global variable  ${return_value}

Отримати інформацію про предмет deliveryAddress.countryName
#Відображення назви нас. пункту доставки номенклатур тендера
  ${return_value}=    Get Element Attribute    xpath=((.//*[@dataanchor='tenderView']//*[@dataanchor='lots'])[1]//*[@dataanchor='lot']//*[@dataanchor='specifications'])[1]//*[@dataanchor='specification']//*[@dataanchor='deliveryAddress']//*[@dataanchor="countryName"]@textContent
  set global variable  ${return_value}

Отримати інформацію про предмет deliveryAddress.postalCode
#Відображення пошт. коду доставки номенклатур тендера
  ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='postalCode'])[1]@textContent
  set global variable  ${return_value}

Отримати інформацію про предмет deliveryAddress.region
#Відображення регіону доставки номенклатур тендера
  ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='region'])[1]@textContent
  set global variable  ${return_value}

Отримати інформацію про предмет deliveryAddress.locality
#Відображення locality адреси доставки номенклатур тендера
  ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='locality'])[1]@textContent
  set global variable  ${return_value}

Отримати інформацію про предмет deliveryAddress.streetAddress
#Відображення вулиці доставки номенклатур тендера
  ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='streetAddress'])[1]@textContent
  set global variable  ${return_value}

Отримати інформацію про предмет classification.scheme
#Відображення схеми основної/додаткової класифікації номенклатур те
  ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='scheme'])[1]@textContent
  set global variable  ${return_value}

Отримати інформацію про предмет classification.id
#Відображення ідентифікатора основної/додаткової класифікації номен
  ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='value'])[1]@textContent
  set global variable  ${return_value}

Отримати інформацію про предмет classification.description
#Відображення опису основної/додаткової класифікації номенклатур те
  ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='description'])[1]@textContent
  set global variable  ${return_value}

Отримати інформацію про предмет unit.name
#Відображення назви одиниці номенклатур тендера
  ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity.unit.name'])[1]@textContent
  set global variable  ${return_value}

Отримати інформацію про предмет unit.code
#Відображення коду одиниці номенклатур тендера
  ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity.unit.code'])[1]@textContent
  set global variable  ${return_value}

Отримати інформацію про предмет quantity
#Відображення кількості номенклатур тендера
  ${return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity'])[1]@textContent
  ${return_value}=  convert to integer     ${return_value}
  set global variable  ${return_value}

Отримати інформацію про предмет deliveryLocation.latitude
#Немає відповідної інформації на майданчику

Отримати інформацію про предмет deliveryLocation.longitude
#Немає відповідної інформації на майданчику

Отримати інформацію про лот title
#Відображення заголовку лотів
  [Arguments]  @{ARGUMENTS}
  ${return_value}=    Execute Javascript      return _.find(angular.element("#robotStatus").scope().data.lots, function(lot){return lot.title.indexOf('${ARGUMENTS[2]}')> -1}).title
  set global variable  ${return_value}

Отримати інформацію про лот value.amount
#Відображення бюджету лотів
  ${return_value}=          get text                xpath=.//span[@dataanchor='amount']
  ${return_value}=          get_numberic_part       ${return_value}
  ${return_value}=    adapt_numbers2   ${return_value}
  set global variable  ${return_value}

Отримати інформацію про лот minimalStep.amount
#Відображення мінімального кроку лотів
  ${return_value}=    Get Element Attribute    xpath=(.//*[@dataanchor='tenderView']//*[@dataanchor='lots'])[1]//*[@dataanchor='lot']//*[@dataanchor='minimalStep.amount']@textContent
  ${return_value}=    get_numberic_part    ${return_value}
  ${return_value}=    adapt_numbers2   ${return_value}
  set global variable  ${return_value}

Отримати інформацію про лот description
#Відображення опису лотів
  ${return_value}=    Get Element Attribute    xpath=(.//div[@ng-if='lot.description.length>0']/div)[2]@textContent
  ${return_value}=    trim data                ${return_value}
  set global variable     ${return_value}

Отримати інформацію про лот value.currency
#Відображення опису лотів
  ${return_value}=    Get Element Attribute    xpath=.//*[@dataanchor='amount']@textContent
  ${return_value}=    get_currency            ${return_value}
  set global variable     ${return_value}

Отримати інформацію про лот value.valueAddedTaxIncluded
#Відображення валюти лотів
  ${return_value}=    Get Element Attribute    xpath=.//span[@dataanchor='valueAddedTaxIncluded']@textContent
  ${return_value}=    tax_adapt                ${return_value}
  set global variable     ${return_value}

Отримати інформацію про лот minimalStep.currency
#Відображення валюти мінімального кроку лотів
  ${return_value}=    Get Element Attribute    xpath=.//*[@dataanchor='minimalStep.amount']@textContent
  ${return_value}=    get_currency            ${return_value}
  set global variable     ${return_value}

Отримати інформацію про лот minimalStep.valueAddedTaxIncluded
#Відображення ПДВ в мінімальному кроці лотів
  ${return_value}=    Get Element Attribute    xpath=.//span[@dataanchor='valueAddedTaxIncluded']@textContent
  ${return_value}=    tax_adapt                ${return_value}
  set global variable     ${return_value}

Отримати інформацію із нецінового показника
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${tender_uaid}
  ...      ${ARGUMENTS[2]} ==  ${object_id}
  ...      ${ARGUMENTS[3]} ==  ${field_name}
  go to  ${ViewTenderUrl}
  sleep  10
  run keyword if  '${ARGUMENTS[3]}' == 'title'                      Отримати інформацію про неціновий показник title          @{ARGUMENTS}
  run keyword if  '${ARGUMENTS[3]}' == 'description'                Отримати інформацію про неціновий показник description    @{ARGUMENTS}
  run keyword if  '${ARGUMENTS[3]}' == 'featureOf'                  Отримати інформацію про неціновий показник featureOf      @{ARGUMENTS}
  [return]  ${feature_return_value}

Отримати інформацію про неціновий показник title
#Відображення заголовку нецінових показників
  [Arguments]  @{ARGUMENTS}
  ${feature_return_value}=    Execute Javascript      return _.find(angular.element("#robotStatus").scope().data.features, function(features){return features.title.indexOf('${ARGUMENTS[2]}')> -1}).title
  set global variable  ${feature_return_value}

Отримати інформацію про неціновий показник description
#Відображення опису нецінових показників
  [Arguments]  @{ARGUMENTS}
  ${feature_return_value}=    Execute Javascript      return _.find(angular.element("#robotStatus").scope().data.features, function(item){return item.title.indexOf('${ARGUMENTS[2]}')> -1}).description
  ${feature_return_value}=    trim data               ${feature_return_value}
  set global variable  ${feature_return_value}

Отримати інформацію про неціновий показник featureOf
#Відображення відношення нецінових показників
  [Arguments]  @{ARGUMENTS}
  ${feature_return_value}=    Execute Javascript      return _.find(angular.element("#robotStatus").scope().data.features, function(item){return item.title.indexOf('${ARGUMENTS[2]}')> -1}).featureOf
  set global variable  ${feature_return_value}

Отримати інформацію із документа
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${tender_uaid}
  ...      ${ARGUMENTS[2]} ==  ${object_id}
  ...      ${ARGUMENTS[3]} ==  ${field_name}
  Go to    ${ViewTenderUrl}
  sleep  10
  ${return_value}=  run keyword  Отримати інформацію із документа ${ARGUMENTS[3]}
  [return]  ${return_value}

Отримати інформацію із документа title
#Відображення заголовку документації до тендера
  ${doc_counter}=  evaluate  ${doc_counter} + ${1}
  set global variable  ${doc_counter}
  click button    xpath=(.//button[@tender-id='control.tenderId'])[1]
  sleep  5
  ${return_value}=    Get Text    xpath=(.//a[@ng-click='loadUrl(gr)'])[${doc_counter}]
  [return]  ${return_value}

Отримати документ
#Відображення вмісту документації до тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${tender_uaid}
  ...      ${ARGUMENTS[2]} ==  ${doc_id}
  Go to    ${ViewTenderUrl}
  sleep  10
  click button    xpath=(.//button[@tender-id='control.tenderId'])[1]
  sleep  5
  ${return_value}=    Get Text    xpath=(.//a[@ng-click='loadUrl(gr)'])[1]
  ${link}=            get value   xpath=(.//a[@ng-click='loadUrl(gr)'])[1]
  download_file       ${link}     ${return_value}      ${OUTPUT_DIR}
  sleep  10
  [return]  ${return_value}

Отримати документ до лоту
#Відображення вмісту документації до всіх лотів
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${tender_uaid}
  ...      ${ARGUMENTS[2]} ==  ${doc_id}
  Go to    ${ViewTenderUrl}
  sleep  10
  click button    xpath=(.//button[@tender-id='control.tenderId'])[1]
  sleep  5
  ${return_value}=    Get Text    xpath=(.//a[@ng-click='loadUrl(gr)'])[2]
  ${link}=            get value   xpath=(.//a[@ng-click='loadUrl(gr)'])[2]
  download_file       ${link}     ${return_value}      ${OUTPUT_DIR}
  sleep  10
  [return]  ${return_value}

Внести зміни в тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  fieldname
  ...      ${ARGUMENTS[3]} ==  fieldvalue
  go to    ${NewTenderUrl}
  Sleep    10
  run keyword if  '${ARGUMENTS[2]}' == 'tenderPeriod.endDate'    Змінити дату в тендері при редагуванні          @{ARGUMENTS}
  run keyword if  '${ARGUMENTS[2]}' == 'description'             Змінити description в тендері при редагуванні   @{ARGUMENTS}

Змінити дату в тендері при редагуванні
#Можливість змінити дату закінчення періоду подання пропозиції на 1
  [Arguments]  @{ARGUMENTS}
  ${time_1}=           convert_datetime_to_new_time    ${ARGUMENTS[3]}
#  go to  ${NewTenderUrl}
#  sleep  10
  Wait Until Page Contains Element   ${locator.edit.${ARGUMENTS[2]}}   20
  Input Text                         ${locator.edit.${ARGUMENTS[2]}}   ${time_1}
  Sleep    3
  Click Button    id=tender-publish
  # Кнопка "Так"
  Wait Until Page Contains Element    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]    20
  Click Button    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  60
  sleep  5

Змінити description в тендері при редагуванні
  [Arguments]  @{ARGUMENTS}
  ${text}=  convert to string  ${ARGUMENTS[3]}
  Input Text       id=description   ${text}
  Sleep    3
  Click Button    id=tender-publish
  # Кнопка "Так"
  Wait Until Page Contains Element    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]    20
  Click Button    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  60

Завантажити документ в лот
#Можливість додати документацію до всіх лотів
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_owner}
  ...      ${ARGUMENTS[1]} ==  ${file_path}
  ...      ${ARGUMENTS[2]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[3]} ==  ${lot_id}
  Go to               ${NewTenderUrl}
  sleep  10
  # Лоти закупівлі
  Execute Javascript    $(angular.element("md-tab-item")[1]).click()
  # +Додати
  sleep  3
  execute javascript  angular.element("#lotDocumentAddAction").click()
  sleep  10
  #Вибір тендерної документації з переліка
  Execute Javascript    $("#type-tender-documents-0").val("biddingDocuments");
  sleep  5
  Choose file     id=file-lot-documents-0   ${ARGUMENTS[1]}
  # Кнопка "Застосувати"
  sleep    3s
  Execute Javascript    $("#tender-apply").click()
  # Кнопка "Опублікувати"
  Page should contain element      id=tender-publish
  Wait Until Element Is Enabled    id=tender-publish
  Click Button    id=tender-publish
  # Кнопка "Так"
  Wait Until Page Contains Element    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]    20
  Click Button    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  3

Змінити лот
#Можливість зменшити бюджет лоту
#Можливість збільшити бюджет лоту
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
    ...    ${ARGUMENTS[2]} ==  ${lot_id}
    ...    ${ARGUMENTS[3]} ==  ${field}
    ...    ${ARGUMENTS[4]} ==  ${value}
  run keyword if  '${ARGUMENTS[3]}' == 'value.amount'                Змінити бюджет лоту                    @{ARGUMENTS}
  run keyword if  '${ARGUMENTS[3]}' == 'minimalStep.amount'          Змінити мінімальний крок лоту          @{ARGUMENTS}

Змінити бюджет лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  Go to           ${NewTenderUrl}
  sleep  10
  ${value_lot}=  convert to string  ${ARGUMENTS[4]}
  # Лоти закупівлі
  Execute Javascript    $(angular.element("md-tab-item")[1]).click()
  Wait Until Page Contains Element   id=amount-lot-value.0   20
  Input Text      id=amount-lot-value.0   ${value_lot}
  sleep  3
  Click Button    id=tender-publish
  # Кнопка "Так"
  Wait Until Page Contains Element    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]    20
  Click Button    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]
  sleep  10

Змінити мінімальний крок лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  Go to           ${NewTenderUrl}
  sleep  10
  ${value_lot}=  convert to string  ${ARGUMENTS[4]}
  # Лоти закупівлі
  Execute Javascript    $(angular.element("md-tab-item")[1]).click()
  Wait Until Page Contains Element   id=amount-lot-value.0   20
  Input Text      id=amount-lot-minimalStep.0   ${value_lot}
  sleep  3
  Click Button    id=tender-publish
  # Кнопка "Так"
  Wait Until Page Contains Element    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]    20
  Click Button    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]
  sleep  10

Додати неціновий показник на лот
#Можливість додати неціновий показник на перший лот
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_owner}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${feature}
  ...      ${ARGUMENTS[3]} ==  ${lot_id}
  run keyword if  '${TENDER_TYPE}' == 'aboveThresholdEU'            Додати неціновий показник на лот aboveThresholdEU   @{ARGUMENTS}
  run keyword if  '${TENDER_TYPE}' == 'aboveThresholdUA'            Додати неціновий показник на лот aboveThresholdUA   @{ARGUMENTS}

Додати неціновий показник на лот aboveThresholdEU
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_owner}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${feature}
  ...      ${ARGUMENTS[3]} ==  ${lot_id}
  #Нецінові крітерії лоту
  ${lot_features_title}=                Get From Dictionary             ${ARGUMENTS[2]}                              title
  ${lot_features_description} =         Get From Dictionary             ${ARGUMENTS[2]}                              description
  ${lot_features_of}=                   Get From Dictionary             ${ARGUMENTS[2]}                              featureOf
  ${lot_non_price_1_value}=             convert to number               ${ARGUMENTS[2].enum[0].value}
  ${lot_non_price_1_value}=             percents                        ${lot_non_price_1_value}
  ${lot_non_price_1_value}=             convert to string               ${lot_non_price_1_value}
  ${lot_non_price_1_title}=             Get From Dictionary             ${ARGUMENTS[2].enum[0]}                      title
  ${lot_non_price_2_value}=             convert to number               ${ARGUMENTS[2].enum[1].value}
  ${lot_non_price_2_value}=             percents                        ${lot_non_price_2_value}
  ${lot_non_price_2_value}=             convert to string               ${lot_non_price_2_value}
  ${lot_non_price_2_title}=             Get From Dictionary             ${ARGUMENTS[2].enum[1]}                      title
  ${lot_non_price_3_value}=             convert to number               ${ARGUMENTS[2].enum[2].value}
  ${lot_non_price_3_value}=             percents                        ${lot_non_price_3_value}
  ${lot_non_price_3_value}=             convert to string               ${lot_non_price_3_value}
  ${lot_non_price_3_title}=             Get From Dictionary             ${ARGUMENTS[2].enum[2]}                      title
  Go to               ${NewTenderUrl}
  sleep  10
  #Переходимо на вкладку "Інші крітерії оцінки"
  Execute Javascript          angular.element("md-tab-item")[2].click()
  sleep  3
  click element               featureAddAction
  sleep  1
  input text                  xpath=(//*[@id="feature.title."])[4]                    ${lot_features_title}
  input text                  xpath=(//*[@id="feature.description."])[4]              ${lot_features_description}
  select from list by value   xpath=(//*[@id="feature.featureOf."])[4]                ${lot_features_of}
  sleep  2
  select from list by label   xpath=(//*[@id="feature.relatedItem."])[3]              ${lot_title}
  sleep  2
  click element               xpath=(//*[@id="enumAddAction"])[4]
  sleep  1
  input text                  enum.title.3.0                                          ${lot_non_price_1_title}
  input text                  enum.value.3.0                                          ${lot_non_price_1_value}
  click element               xpath=(//*[@id="enumAddAction"])[4]
  sleep  1
  input text                  enum.title.3.1                                          ${lot_non_price_2_title}
  input text                  enum.value.3.1                                          ${lot_non_price_2_value}
  click element               xpath=(//*[@id="enumAddAction"])[4]
  sleep  1
  input text                  enum.title.3.2                                          ${lot_non_price_3_title}
  input text                  enum.value.3.2                                          ${lot_non_price_3_value}
  # Кнопка "Опубліковати"
  sleep  3
  Click Button    id=tender-publish
  # Кнопка "Так"
  Wait Until Page Contains Element    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]    20
  Click Button    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]
  sleep  10

Додати неціновий показник на лот aboveThresholdUA
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_owner}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${feature}
  ...      ${ARGUMENTS[3]} ==  ${lot_id}
  #Нецінові крітерії лоту
  ${lot_features_title}=                Get From Dictionary             ${ARGUMENTS[2]}                              title
  ${lot_features_description} =         Get From Dictionary             ${ARGUMENTS[2]}                              description
  ${lot_features_of}=                   Get From Dictionary             ${ARGUMENTS[2]}                              featureOf
  ${lot_non_price_1_value}=             convert to number               ${ARGUMENTS[2].enum[0].value}
  ${lot_non_price_1_value}=             percents                        ${lot_non_price_1_value}
  ${lot_non_price_1_value}=             convert to string               ${lot_non_price_1_value}
  ${lot_non_price_1_title}=             Get From Dictionary             ${ARGUMENTS[2].enum[0]}                      title
  ${lot_non_price_2_value}=             convert to number               ${ARGUMENTS[2].enum[1].value}
  ${lot_non_price_2_value}=             percents                        ${lot_non_price_2_value}
  ${lot_non_price_2_value}=             convert to string               ${lot_non_price_2_value}
  ${lot_non_price_2_title}=             Get From Dictionary             ${ARGUMENTS[2].enum[1]}                      title
  ${lot_non_price_3_value}=             convert to number               ${ARGUMENTS[2].enum[2].value}
  ${lot_non_price_3_value}=             percents                        ${lot_non_price_3_value}
  ${lot_non_price_3_value}=             convert to string               ${lot_non_price_3_value}
  ${lot_non_price_3_title}=             Get From Dictionary             ${ARGUMENTS[2].enum[2]}                      title
  Go to               ${NewTenderUrl}
  sleep  10
  #Переходимо на вкладку "Інші крітерії оцінки"
  Execute Javascript          angular.element("md-tab-item")[2].click()
  sleep  3
  click element               featureAddAction
  sleep  1
  input text                  xpath=(//*[@id="feature.title."])[5]                    ${lot_features_title}
  input text                  xpath=(//*[@id="feature.description."])[5]              ${lot_features_description}
  select from list by value   xpath=(//*[@id="feature.featureOf."])[5]                ${lot_features_of}
  sleep  2
  select from list by label   xpath=(//*[@id="feature.relatedItem."])[4]              ${lot_title}
  sleep  2
  click element               xpath=(//*[@id="enumAddAction"])[5]
  sleep  1
  input text                  enum.title.4.0                                          ${lot_non_price_1_title}
  input text                  enum.value.4.0                                          ${lot_non_price_1_value}
  click element               xpath=(//*[@id="enumAddAction"])[5]
  sleep  1
  input text                  enum.title.4.1                                          ${lot_non_price_2_title}
  input text                  enum.value.4.1                                          ${lot_non_price_2_value}
  click element               xpath=(//*[@id="enumAddAction"])[5]
  sleep  1
  input text                  enum.title.4.2                                          ${lot_non_price_3_title}
  input text                  enum.value.4.2                                          ${lot_non_price_3_value}
  # Кнопка "Опубліковати"
  sleep  3
  Click Button    id=tender-publish
  # Кнопка "Так"
  Wait Until Page Contains Element    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]    20
  Click Button    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]
  sleep  10








Відповісти на запитання
#Можливість відповісти на запитання на всі лоти
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_owner}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${answer}
  ...      ${ARGUMENTS[3]} ==  ${USERS.users['${provider}'].tender_question_data.question_id}
  Go to    ${ViewTenderUrl}
  sleep  10
  ${answer}=  convert to string  ${ARGUMENTS[2].data.answer}
  wait until element is visible  id=answer
  input text  id=answer  ${answer}
  sleep  2
  click element  xpath=.//button[@ng-click='answerQuestion()']
  sleep  2
  run keyword and ignore error  click element  xpath=.//button[@ng-click='answerQuestion()']
  sleep  10

Видалити неціновий показник
#Можливість видалити неціновий показник на лот
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_owner}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${feature_id}
  go to    ${NewTenderUrl}
  sleep  10
  #Переходимо на вкладку "Інші крітерії оцінки"
  Execute Javascript          angular.element("md-tab-item")[2].click()
  sleep  10
  execute javascript  angular.element("app-tender-features")[3].getElementsByTagName("button")[0].click()
  # Кнопка "Опубліковати"
  sleep  3
  Click Button    id=tender-publish
  # Кнопка "Так"
  Wait Until Page Contains Element    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]    20
  Click Button    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  3

Отримати інформацію із запитання
#Відображення заголовку анонімного запитання на всі лоти без відповіді
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${tender_uaid}
  ...      ${ARGUMENTS[2]} ==  ${object_id}
  ...      ${ARGUMENTS[3]} ==  ${field_name}
  go to     ${ViewTenderUrl}
  sleep  10
  run keyword if  '${ARGUMENTS[3]}' == 'title'                      Отримати інформацію про title запитання          @{ARGUMENTS}
  run keyword if  '${ARGUMENTS[3]}' == 'description'                Отримати інформацію про description запитання
  run keyword if  '${ARGUMENTS[3]}' == 'answer'                     Отримати інформацію про answer запитання
  [return]  ${question_value}

Отримати інформацію про title запитання
  [Arguments]  @{ARGUMENTS}
  sleep  5
  ${question_value}=    get element attribute  xpath=.//span[@dataanchor='title']@textContent
  set global variable            ${question_value}

Отримати інформацію про description запитання
#Відображення опису анонімного запитання на всі лоти без відповіді
  ${question_value}=    get element attribute  xpath=.//div/div[@class='tender-question-description-row ng-binding']@textContent
  set global variable            ${question_value}

Отримати інформацію про answer запитання
#Відображення опису анонімного запитання на всі лоти без відповіді
  ${question_value}=    get element attribute  xpath=.//div[@ng-if='question.answer']@textContent
  set global variable            ${question_value}

#Отримати інформацію про answer запитання
##Відображення опису анонімного запитання на всі лоти без відповіді
#  sleep  10
#  ${question_value}=    get element attribute  xpath=.//div[@ng-if='question.answer']/p@textContent
#  set global variable            ${question_value}

Завантажити документ у кваліфікацію
#Можливість завантажити документ у кваліфікацію пропозиції першого
#Можливість завантажити документ у кваліфікацію пропозиції другого
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${file_path}
  ...      ${ARGUMENTS[2]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[3]} ==  ${bid_index}
  go to     ${ViewTenderUrl}
  sleep  10
  click element  id=qualification-active-${ARGUMENTS[3]}
  wait until element is visible  id=qualification-document-add  30
  sleep  1
  click element  id=qualification-document-add
  sleep  5
  input text     id=description-qualification-documents-0       PLACEHOLDER
  choose file    id=file-qualification-documents-0              ${ARGUMENTS[1]}
  sleep  2
  click element  id=qualification-qualified
  click element  id=qualification-eligible
  click element  xpath=.//button[@type='submit']
  sleep  15

Підтвердити кваліфікацію
#Можливість підтвердити другу пропозицію кваліфікації
#Можливість підтвердити першу пропозицію кваліфікації
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_owner}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${bid_index}
  sleep  10

Затвердити остаточне рішення кваліфікації
#Можливість затвердити остаточне рішення кваліфікації
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_owner}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  go to     ${ViewTenderUrl}
  sleep  10
  click element  id=tender-accept-qualification
  # Кнопка "Так"
  Wait Until Page Contains Element    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]    20
  Click Button    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  3

Задати запитання на лот
#Можливість задати запитання на всі лоти
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  ${username}
    ...    ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
    ...    ${ARGUMENTS[2]} ==  ${lot_id}
    ...    ${ARGUMENTS[2]} ==  ${question}
  go to  ${ViewTenderUrl}
  sleep  10
  ${title}=             get from dictionary  ${ARGUMENTS[3].data}  title
  ${description}=       get from dictionary  ${ARGUMENTS[3].data}  description
  focus          xpath=.//button[@ng-click='toggleView()']
  sleep  3
  click element  xpath=.//button[@ng-click='toggleView()']
  sleep  3
  input text     id=title          ${title}
  input text     id=description    ${description}
  focus          id=questionOf
  sleep  2
  click element  id=questionOf
  sleep  3
  click element  xpath=(.//md-option[@class='md-ink-ripple'])[2]
  sleep  3
  focus          id=relatedItem
  sleep  2
  click element  id=relatedItem
  sleep  3
  click element  xpath=.//md-option[@ng-value='i.key']
  sleep  3
  focus          xpath=.//button[@ng-click='createQuestion()']
  sleep  2
  click element  xpath=.//button[@ng-click='createQuestion()']
  sleep  10

Отримати інформацію із пропозиції
#Можливість зменшити пропозицію на 5% першим учасником
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  ${username}
    ...    ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
    ...    ${ARGUMENTS[2]} ==  ${field}
  go to  ${ViewTenderUrl}
  sleep  10
  ${return_value}=  run keyword  Отримати інформацію із пропозиції про ${ARGUMENTS[2]}
  [return]  ${return_value}

Отримати інформацію із пропозиції про lotValues[0].value.amount
  ${return_value}=  get value               id=lot-amount-0
  ${return_value}=  get numberic part       ${return_value}
  ${return_value}=  adapt_numbers2          ${return_value}
  log to console  adapt_numbers2 ${return_value}
  [return]  ${return_value}

Отримати інформацію із пропозиції про status
#Відображення зміни статусу першої пропозиції після редагування інф
  wait until element is visible  xpath=.//md-chip[@class='warning-chip ng-binding ng-scope']  60
  ${var}=  set variable  invalid
  [return]  ${var}

Змінити цінову пропозицію
#Можливість зменшити пропозицію на 5% першим учасником
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  ${username}
    ...    ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
    ...    ${ARGUMENTS[2]} ==  ${field}
    ...    ${ARGUMENTS[3]} ==  ${value}
    go to  ${ViewTenderUrl}
    sleep  10
    run keyword if  '${ARGUMENTS[3]}' != 'pending'  Змінюємо цінову пропозицію на 5%  @{ARGUMENTS}
    run keyword and ignore error  click element       id=tender-confirm-bid
    sleep  2
    wait until element is visible  xpath=.//button[@ng-click='ok()']  60
    click element                  xpath=.//button[@ng-click='ok()']
    sleep  10

Змінюємо цінову пропозицію на 5%
    [Arguments]  @{ARGUMENTS}
    ${var} =            adapt_numbers                     ${ARGUMENTS[3]}
    ${var} =            convert to string                 ${var}
    Input Text          id=lot-amount-0                   ${var}
    sleep   5
    Click Element       id=tender-update-bid

Завантажити документ в ставку
#Можливість завантажити документ в пропозицію першим учасником
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  ${username}
    ...    ${ARGUMENTS[1]} ==  ${file_path}
    ...    ${ARGUMENTS[2]} ==  ${TENDER['TENDER_UAID']}
    run keyword if  '${TENDER_TYPE}' == 'aboveThresholdEU'            Завантажити документ в ставку aboveThresholdEU   @{ARGUMENTS}
    run keyword if  '${TENDER_TYPE}' == 'aboveThresholdUA'            Завантажити документ в ставку aboveThresholdUA   @{ARGUMENTS}

Завантажити документ в ставку aboveThresholdEU
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...    ${ARGUMENTS[0]} ==  ${username}
  ...    ${ARGUMENTS[1]} ==  ${file_path}
  ...    ${ARGUMENTS[2]} ==  ${TENDER['TENDER_UAID']}
  go to  ${ViewTenderUrl}
  sleep  10
  ${bid_doc_type}=  convert to string  commercialProposal
  set global variable  ${bid_doc_type}
  run keyword and ignore error  Отримати тип документу ставки  @{ARGUMENTS}
  execute javascript  $($("ng-form[name='bidForm']").find("button[ng-if='vm.allowEditBidDocuments']")[0]).trigger('click')
  sleep  5
  focus   xpath=.//span[@class='upper-case-block-label ng-binding']
  sleep  2
  select from list by value     id=type-bid-documents                     ${bid_doc_type}
  sleep  2
  Choose file     id=file-bid-documents    ${ARGUMENTS[1]}
  Sleep  10
  # Кнопка "Додати пропозицію"
  Click element    id=tender-update-bid
  wait until element is visible  xpath=.//button[@ng-click='ok()']  60
  click element                  xpath=.//button[@ng-click='ok()']
  sleep  10

Завантажити документ в ставку aboveThresholdUA
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...    ${ARGUMENTS[0]} ==  ${username}
  ...    ${ARGUMENTS[1]} ==  ${file_path}
  ...    ${ARGUMENTS[2]} ==  ${TENDER['TENDER_UAID']}
  go to  ${ViewTenderUrl}
  sleep  10
  ${bid_doc_type}=  convert to string  commercialProposal
  set global variable  ${bid_doc_type}
  run keyword and ignore error  Отримати тип документу ставки  @{ARGUMENTS}
  Wait Until Page Contains Element    xpath=(.//button[@ng-if='vm.allowEditBidDocuments'])[1]
  focus                               xpath=(.//button[@ng-if='vm.allowEditBidDocuments'])[1]
  sleep  5
  focus                               xpath=(.//button[@ng-if='vm.allowEditBidDocuments'])[1]
  sleep  5
  Click element                       xpath=(.//button[@ng-if='vm.allowEditBidDocuments'])[1]
  Sleep  5
  focus  id=description-bid-documents
  sleep  5
  input text                    id=description-bid-documents              PLACEHOLDER
  focus  id=type-bid-documents
  sleep  5
  select from list by value     id=type-bid-documents                     ${bid_doc_type}
  sleep  2
  Choose file     id=file-bid-documents    ${ARGUMENTS[1]}
  Sleep  10
  # Кнопка "Додати пропозицію"
  Click element    id=tender-update-bid
  wait until element is visible  xpath=.//button[@ng-click='ok()']  60
  click element                  xpath=.//button[@ng-click='ok()']
  sleep  10

Отримати тип документу ставки
  [Arguments]  @{ARGUMENTS}
  ${bid_doc_type}=  convert to string  ${ARGUMENTS[3]}
  ${bid_doc_type}=  adapt_doc_type     ${bid_doc_type}
  set global variable  ${bid_doc_type}

Змінити документ в ставці
#Можливість змінити документацію цінової пропозиції першим учасником
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...    ${ARGUMENTS[0]} ==  username
  ...    ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...    ${ARGUMENTS[2]} ==  ${file_path}
  ...    ${ARGUMENTS[3]} ==  ${USERS.users['${username}']['bid_document']['doc_id']}
  go to  ${ViewTenderUrl}
  sleep  10
  execute javascript  $($("ng-form[name='bidForm']").find("button[ng-if='vm.allowEditBidDocuments']")[0]).trigger('click')
  focus   xpath=.//span[@class='upper-case-block-label ng-binding']
  sleep   5
  select from list by value     id=type-bid-documents                     commercialProposal
  sleep  2
  Choose file     id=file-bid-documents    ${ARGUMENTS[2]}
  Sleep  10
  # Кнопка "Додати пропозицію"
  Click element    id=tender-update-bid
  wait until element is visible  xpath=.//button[@ng-click='ok()']  60
  click element                  xpath=.//button[@ng-click='ok()']
  sleep  10

Змінити документацію в ставці
#Можливість змінити документацію цінової пропозиції з публічної на приватну учасником
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${privat_doc}
  ...      ${ARGUMENTS[3]} ==  ${USERS.users['${username}']['bid_document']['doc_id']}
  ${confidentialityRationale}=  convert to string  ${ARGUMENTS[2].data.confidentialityRationale}
  go to     ${ViewTenderUrl}
  sleep  10
  focus          xpath=(.//button[@ng-click='toggleEditMode(true)'])[2]
  sleep  2
  click element  xpath=(.//button[@ng-click='toggleEditMode(true)'])[2]
  focus          xpath=.//md-checkbox[@ng-model='value.confidentiality']
  sleep  2
  click element  xpath=.//md-checkbox[@ng-model='value.confidentiality']
  sleep  2
  input text     confidentialityRationale-bid-documents                     ${confidentialityRationale}
  # Кнопка "Додати пропозицію"
  Click element    id=tender-update-bid
  wait until element is visible  xpath=.//button[@ng-click='ok()']  60
  click element                  xpath=.//button[@ng-click='ok()']
  sleep  10

Задати запитання на тендер
#Неможливість задати запитання на тендер після закінчення періоду у
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${question}
  Go to    ${ViewTenderUrl}
  Sleep    10
  ${title}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=  Get From Dictionary  ${ARGUMENTS[2].data}  description
  Wait Until Page Contains Element   xpath=//ng-form[@name='questionForm'][1]//button[@ng-click='toggleView()']  30
  focus  xpath=//ng-form[@name='questionForm'][1]//button[@ng-click='toggleView()']
  sleep  3
  Click element     xpath=//ng-form[@name='questionForm'][1]//button[@ng-click='toggleView()']
  Sleep    5s
  input text       id=title          ${title}
  input text       id=description    ${description}
  Sleep    10
  focus  xpath=//ng-form[@name='questionForm'][1]//button[@ng-click='createQuestion()']
  sleep  5
  Click element     xpath=//ng-form[@name='questionForm'][1]//button[@ng-click='createQuestion()']
  Sleep    20

Задати запитання на предмет
#Неможливість задати запитання на перший предмет після закінчення п
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${item_id}
  ...      ${ARGUMENTS[3]} ==  ${question}
  Go to    ${ViewTenderUrl}
  Sleep    10
  Wait Until Page Contains Element   xpath=//ng-form[@name='questionForm'][1]//button[@ng-click='toggleView()']
  Click element     xpath=//ng-form[@name='questionForm'][1]//button[@ng-click='toggleView()']
  Sleep    5s

Отримати посилання на аукціон для глядача
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...      ${ARGUMENTS[0]} ==  ${username}
    ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
    Go to    ${ViewTenderUrl}
    Sleep    10
    Wait Until Page Contains Element    xpath=.//div/a[@target='_blank']   60
    ${result} =   Get Element Attribute    xpath=.//div/a[@target='_blank']@href
    log to console  *
    log to console  ${result}
    [return]   ${result}

Отримати посилання на аукціон для учасника
#Можливість вичитати посилання на аукціон для першого учасника
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...      ${ARGUMENTS[0]} ==  ${username}
    ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
    Go to    ${ViewTenderUrl}
    Sleep    10
    Wait Until Page Contains Element    xpath=.//div/a[@target='_blank']   60
    ${result} =   Get Element Attribute    xpath=.//div/a[@target='_blank']@href
    [return]   ${result}

Отримати інформацію про тендер title
#Відображення заголовку тендера
  ${return_value}=    Execute Javascript      return angular.element("#robotStatus").scope().data.title
  [return]  ${return_value}

Отримати інформацію про тендер description
#Відображення опису тендера
  ${return_value}=    Get Text    xpath=(.//*[@dataanchor='tenderView']//*[@dataanchor='description'])[1]
  [return]  ${return_value}

Отримати інформацію про тендер value.currency
#Відображення валюти тендера
  ${return_value}=    Get Text    xpath=.//*[@dataanchor='tenderView']//*[@dataanchor='value.currency']
  [return]  ${return_value}

Отримати інформацію про тендер value.valueAddedTaxIncluded
#Відображення ПДВ в бюджеті тендера
    wait until element is visible  xpath=.//*[@dataanchor='tenderView']//*[@dataanchor='value.valueAddedTaxIncluded']  20
    ${tax}=              Get Text  xpath=.//*[@dataanchor='tenderView']//*[@dataanchor='value.valueAddedTaxIncluded']
    ${return_value}=    tax adapt  ${tax}
    [return]  ${return_value}

Отримати інформацію про тендер tenderID
#Відображення ідентифікатора тендера
    wait until element is visible  id=tenderID  20
    ${return_value}=    Get Text   id=tenderID
    [return]    ${return_value}

Отримати інформацію про тендер procuringEntity.name
#Відображення імені замовника тендера
    wait until element is visible  xpath=.//div[@class='align-text-at-center flex-none']  20
	${return_value}=     Get Text  xpath=.//div[@class='align-text-at-center flex-none']
    [return]  ${return_value}

Отримати інформацію про тендер minimalStep.amount
#Відображення мінімального кроку тендера
	${return_value}=    Get Element Attribute    xpath=(.//*[@dataanchor='tenderView']//*[@dataanchor='lots'])[1]//*[@dataanchor='lot']//*[@dataanchor='minimalStep.amount']@textContent
	${return_value}=    get_numberic_part    ${return_value}
	${return_value}=    Convert To Number    ${return_value}
    [return]  ${return_value}

Додати неціновий показник на предмет
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_owner}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${feature}
  ...      ${ARGUMENTS[3]} ==  ${item_id}

  ${item_features_title}=                Get From Dictionary             ${ARGUMENTS[2]}                              title
  ${item_features_description} =         Get From Dictionary             ${ARGUMENTS[2]}                              description
  ${item_features_of}=                   Get From Dictionary             ${ARGUMENTS[2]}                              featureOf
  ${item_non_price_1_value}=             convert to number               ${ARGUMENTS[2].enum[0].value}
  ${item_non_price_1_value}=             percents                        ${item_non_price_1_value}
  ${item_non_price_1_value}=             convert to string               ${item_non_price_1_value}
  ${item_non_price_1_title}=             Get From Dictionary             ${ARGUMENTS[2].enum[0]}                      title
  ${item_non_price_2_value}=             convert to number               ${ARGUMENTS[2].enum[1].value}
  ${item_non_price_2_value}=             percents                        ${item_non_price_2_value}
  ${item_non_price_2_value}=             convert to string               ${item_non_price_2_value}
  ${item_non_price_2_title}=             Get From Dictionary             ${ARGUMENTS[2].enum[1]}                      title
  ${item_non_price_3_value}=             convert to number               ${ARGUMENTS[2].enum[2].value}
  ${item_non_price_3_value}=             percents                        ${item_non_price_3_value}
  ${item_non_price_3_value}=             convert to string               ${item_non_price_3_value}
  ${item_non_price_3_title}=             Get From Dictionary             ${ARGUMENTS[2].enum[2]}                      title
  Go to               ${NewTenderUrl}
  log to console  ${ARGUMENTS[2]}
  sleep  10
  #Переходимо на вкладку "Інші крітерії оцінки"
  Execute Javascript          angular.element("md-tab-item")[2].click()
  sleep  3
  click element               featureAddAction
  sleep  1
  input text                  xpath=(//*[@id="feature.title."])[4]                    ${item_features_title}
  input text                  xpath=(//*[@id="feature.description."])[4]              ${item_features_description}
  select from list by value   xpath=(//*[@id="feature.featureOf."])[4]                ${item_features_of}
  sleep  2
  select from list by label   xpath=(//*[@id="feature.relatedItem."])[3]              ${item_description}
  sleep  2
  click element               xpath=(//*[@id="enumAddAction"])[4]
  sleep  1
  input text                  enum.title.3.0                                          ${item_non_price_1_title}
  input text                  enum.value.3.0                                          ${item_non_price_1_value}
  click element               xpath=(//*[@id="enumAddAction"])[4]
  sleep  1
  input text                  enum.title.3.1                                          ${item_non_price_2_title}
  input text                  enum.value.3.1                                          ${item_non_price_2_value}
  click element               xpath=(//*[@id="enumAddAction"])[4]
  sleep  1
  input text                  enum.title.3.2                                          ${item_non_price_3_title}
  input text                  enum.value.3.2                                          ${item_non_price_3_value}
  # Кнопка "Опубліковати"
  sleep  3
  Click Button    id=tender-publish
  # Кнопка "Так"
  Wait Until Page Contains Element    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]    20
  Click Button    xpath=//div[@class="modal-dialog "]//button[@ng-click="ok()"]
  sleep  10


















