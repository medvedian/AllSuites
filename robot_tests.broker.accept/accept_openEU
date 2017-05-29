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
${Поле "Підстава для використання"}  id=  cause
${Поле "Підстава для використання" варіант "Потреба здійснити додаткову закупівлю"}  xpath=  //div [@class='md-select-menu-container md-active md-clickable']//md-select-menu [@class='_md']//md-content[@class='_md']//md-option[4]
${Перший елемент класифікатора ДК 021:2015}  id=  03000000-1_0_anchor
#${Поле "Одиниці виміру" варіант "ампер"}  xpath=  //*[@id="unit-unit--"]/option[2]
${Кнопка "Опублікувати"}  id=  tender-publish
${Кнопка "Так" у попап вікні}  xpath=  /html/body/div[1]/div/div/div[3]/button[1]
${Посилання на тендер}  id=  tenderUID
${Кнопка "Зберегти учасника переговорів"}  id=  tender-create-award
${Поле "Ціна пропозиції"}  id=  award-value-amount
${Поле "Тип документа" (Кваліфікація учасників)}  id=  type-award-document
${Поле "Пошук" у класифікаторі}  id=  search-input-cpv-0-0
${locator.edit.description}    id=description
${locator.procuringEntity.name}    xpath=//*[@id="tab-content-20"]/div/md-content/div[2]/div[1]/div[2]
${locator.edit.tenderPeriod.endDate}  id=timeInput
${locator.edit.value.amount}    id=amount-lot-value.0


*** Keywords ***
Підготувати клієнт для користувача
  [Arguments]     @{ARGUMENTS}
  [Documentation]  Відкрити брaвзер, створити обєкт api wrapper, тощо
  Open Browser  ${USERS.users['${ARGUMENTS[0]}'].homepage}  ${USERS.users['${ARGUMENTS[0]}'].browser}  alias=${ARGUMENTS[0]}
  maximize browser window
#  set window size  1300  900
#  set window position   610  0
  Login   ${ARGUMENTS[0]}

Login
  [Arguments]  @{ARGUMENTS}
  wait until element is visible  ${Кнопка "Вхід"}
  Click Button                   ${Кнопка "Вхід"}
  wait until element is visible  id=username
  Input text                     id=username          ${USERS.users['${ARGUMENTS[0]}'].login}
  Input text                     id=password          ${USERS.users['${ARGUMENTS[0]}'].password}
  Click Button                   id=loginButton

Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${items}
    run keyword if  '${username}' == 'accOwner'      ${tender_data}=       adapt_data         ${tender_data}
#    log to console  *
#    log to console  ${tender_data}
#    log to console  *
    [return]    ${tender_data}

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
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
    ${ViewTenderUrl}=  assemble_viewtender_url  ${NewTenderUrl}  ${tender_id}
	SET GLOBAL VARIABLE                         ${ViewTenderUrl}
	log to console  ${ViewTenderUrl}
    [return]  ${TENDER_UA}

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

Заповнюємо додаткові коди
    Execute Javascript    angular.element("#cpv").scope().value.additionalClassifications = [{id: "${add_id}", description: "${add_descr}", scheme: "${add_scheme}"}];
    sleep  2

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
  #натискаємо кнопку пошук
  click element  xpath=(.//span[@class='ng-binding ng-scope'])[2]
  sleep  5
  # Кнопка  "Розширений пошук"
  Click Button    xpath=//tender-search-panel//div[@class='advanced-search-control']//button[contains(@ng-click, 'advancedSearchHidden')]
  sleep  2
  Input Text      id=identifier    ${ARGUMENTS[1]}
  Click Button    id=searchButton
  Sleep  10
  click element  xpath=(.//div[@class='resultItemHeader'])[1]/a
  sleep  10
  ${ViewTenderUrl}=    Execute Javascript    return window.location.href
  SET GLOBAL VARIABLE    ${ViewTenderUrl}
  sleep  1

#############КЕЙВОРДИ ДЛЯ ВІДОБРАЖЕННЯ ІНФОРМАЦІЇ ПРО ТЕНДЕР#######################################################

Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${tender_uaid}
  ...      ${ARGUMENTS[2]} ==  ${field}
  go to  ${ViewTenderUrl}
  sleep  10
  ${return_value}=  run keyword  Отримати інформацію про тендер ${ARGUMENTS[2]}
  [return]  ${return_value}

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


###################################################################################################################################################################

Отримати інформацію із предмету
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
  [return]  ${item_return_value}

Отримати інформацію про предмет description
#Відображення опису номенклатур тендера
  [Arguments]  @{ARGUMENTS}
  ${item_return_value}=    Execute Javascript      return _.find(angular.element("#robotStatus").scope().data.items, function(item){return item.description.indexOf('${ARGUMENTS[2]}')> -1}).description
  set global variable  ${item_return_value}

Отримати інформацію про предмет deliveryDate.startDate
#Відображення дати початку доставки номенклатур тендера
  ${item_return_value}=    Execute Javascript    return angular.element(document.querySelectorAll("[dataanchor='tenderView']")[0].querySelectorAll("[dataanchor='lots']")[0].querySelectorAll("[dataanchor='lot']")[0].querySelectorAll("[dataanchor='specifications']")[0].querySelectorAll("[dataanchor='specification']")[0]).scope().lotItem.items[0].deliveryDate.startDate
  set global variable  ${item_return_value}

Отримати інформацію про предмет deliveryDate.endDate
#Відображення дати кінця доставки номенклатур тендера
  ${item_return_value}=    Execute Javascript    return angular.element(document.querySelectorAll("[dataanchor='tenderView']")[0].querySelectorAll("[dataanchor='lots']")[0].querySelectorAll("[dataanchor='lot']")[0].querySelectorAll("[dataanchor='specifications']")[0].querySelectorAll("[dataanchor='specification']")[0]).scope().lotItem.items[0].deliveryDate.endDate
  set global variable  ${item_return_value}

Отримати інформацію про предмет deliveryAddress.countryName
#Відображення назви нас. пункту доставки номенклатур тендера
  ${item_return_value}=    Get Element Attribute    xpath=((.//*[@dataanchor='tenderView']//*[@dataanchor='lots'])[1]//*[@dataanchor='lot']//*[@dataanchor='specifications'])[1]//*[@dataanchor='specification']//*[@dataanchor='deliveryAddress']//*[@dataanchor="countryName"]@textContent
  set global variable  ${item_return_value}

Отримати інформацію про предмет deliveryAddress.postalCode
#Відображення пошт. коду доставки номенклатур тендера
  ${item_return_value}=  get element attribute  xpath=(.//span[@dataanchor='postalCode'])[1]@textContent
  set global variable  ${item_return_value}

Отримати інформацію про предмет deliveryAddress.region
#Відображення регіону доставки номенклатур тендера
  ${item_return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='region'])[1]@textContent
  set global variable  ${item_return_value}

Отримати інформацію про предмет deliveryAddress.locality
#Відображення locality адреси доставки номенклатур тендера
  ${item_return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='locality'])[1]@textContent
  set global variable  ${item_return_value}

Отримати інформацію про предмет deliveryAddress.streetAddress
#Відображення вулиці доставки номенклатур тендера
  ${item_return_value}=  get element attribute  xpath=(.//span[@dataanchor='deliveryAddress']/span[@dataanchor='streetAddress'])[1]@textContent
  set global variable  ${item_return_value}

Отримати інформацію про предмет classification.scheme
#Відображення схеми основної/додаткової класифікації номенклатур те
  ${item_return_value}=  get element attribute  xpath=(.//span[@dataanchor='scheme'])[1]@textContent
  set global variable  ${item_return_value}

Отримати інформацію про предмет classification.id
#Відображення ідентифікатора основної/додаткової класифікації номен
  ${item_return_value}=  get element attribute  xpath=(.//span[@dataanchor='value'])[1]@textContent
  set global variable  ${item_return_value}

Отримати інформацію про предмет classification.description
#Відображення опису основної/додаткової класифікації номенклатур те
  ${item_return_value}=  get element attribute  xpath=(.//span[@dataanchor='description'])[1]@textContent
  set global variable  ${item_return_value}

Отримати інформацію про предмет unit.name
#Відображення назви одиниці номенклатур тендера
  ${item_return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity.unit.name'])[1]@textContent
  set global variable  ${item_return_value}

Отримати інформацію про предмет unit.code
#Відображення коду одиниці номенклатур тендера
  ${item_return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity.unit.code'])[1]@textContent
  set global variable  ${item_return_value}

Отримати інформацію про предмет quantity
#Відображення кількості номенклатур тендера
  ${item_return_value}=  get element attribute  xpath=(.//span[@dataanchor='quantity'])[1]@textContent
  ${item_return_value}=  convert to integer     ${item_return_value}
  set global variable  ${item_return_value}

Отримати інформацію про предмет deliveryLocation.latitude
#Немає відповідної інформації на майданчику

Отримати інформацію про предмет deliveryLocation.longitude
#Немає відповідної інформації на майданчику

Отримати інформацію із лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${tender_uaid}
  ...      ${ARGUMENTS[2]} ==  ${object_id}
  ...      ${ARGUMENTS[3]} ==  ${field_name}
  go to  ${ViewTenderUrl}
  sleep  10
  run keyword if  '${ARGUMENTS[3]}' == 'title'                                  Отримати інформацію про лот title                  @{ARGUMENTS}
  run keyword if  '${ARGUMENTS[3]}' == 'value.amount'                           Отримати інформацію про лот value.amount
  run keyword if  '${ARGUMENTS[3]}' == 'minimalStep.amount'                     Отримати інформацію про лот minimalStep.amount
  run keyword if  '${ARGUMENTS[3]}' == 'description'                            Отримати інформацію про лот description
  run keyword if  '${ARGUMENTS[3]}' == 'value.currency'                         Отримати інформацію про лот value.currency
  run keyword if  '${ARGUMENTS[3]}' == 'value.valueAddedTaxIncluded'            Отримати інформацію про лот value.valueAddedTaxIncluded
  run keyword if  '${ARGUMENTS[3]}' == 'minimalStep.currency'                   Отримати інформацію про лот minimalStep.currency
  run keyword if  '${ARGUMENTS[3]}' == 'minimalStep.valueAddedTaxIncluded'      Отримати інформацію про лот minimalStep.valueAddedTaxIncluded
  [return]  ${lot_return_value}

Отримати інформацію про лот title
#Відображення заголовку лотів
  [Arguments]  @{ARGUMENTS}
  ${lot_return_value}=    Execute Javascript      return _.find(angular.element("#robotStatus").scope().data.lots, function(lot){return lot.title.indexOf('${ARGUMENTS[2]}')> -1}).title
  set global variable  ${lot_return_value}

Отримати інформацію про лот value.amount
#Відображення бюджету лотів
  ${lot_return_value}=          get text                xpath=.//span[@dataanchor='amount']
  ${lot_return_value}=          get_numberic_part       ${lot_return_value}
  ${lot_return_value}=    adapt_numbers2   ${lot_return_value}
  set global variable  ${lot_return_value}

Отримати інформацію про лот minimalStep.amount
#Відображення мінімального кроку лотів
  ${lot_return_value}=    Get Element Attribute    xpath=(.//*[@dataanchor='tenderView']//*[@dataanchor='lots'])[1]//*[@dataanchor='lot']//*[@dataanchor='minimalStep.amount']@textContent
  ${lot_return_value}=    get_numberic_part    ${lot_return_value}
  ${lot_return_value}=    adapt_numbers2   ${lot_return_value}
  set global variable  ${lot_return_value}

Отримати інформацію про лот description
#Відображення опису лотів
  ${lot_return_value}=    Get Element Attribute    xpath=(.//div[@ng-if='lot.description.length>0']/div)[2]@textContent
  ${lot_return_value}=    trim data                ${lot_return_value}
  set global variable     ${lot_return_value}

Отримати інформацію про лот value.currency
#Відображення опису лотів
  ${lot_return_value}=    Get Element Attribute    xpath=.//*[@dataanchor='amount']@textContent
  ${lot_return_value}=    get_currency            ${lot_return_value}
  set global variable     ${lot_return_value}

Отримати інформацію про лот value.valueAddedTaxIncluded
#Відображення валюти лотів
  ${lot_return_value}=    Get Element Attribute    xpath=.//span[@dataanchor='valueAddedTaxIncluded']@textContent
  ${lot_return_value}=    tax_adapt                ${lot_return_value}
  set global variable     ${lot_return_value}

Отримати інформацію про лот minimalStep.currency
#Відображення валюти мінімального кроку лотів
  ${lot_return_value}=    Get Element Attribute    xpath=.//*[@dataanchor='minimalStep.amount']@textContent
  ${lot_return_value}=    get_currency            ${lot_return_value}
  set global variable     ${lot_return_value}

Отримати інформацію про лот minimalStep.valueAddedTaxIncluded
#Відображення ПДВ в мінімальному кроці лотів
  ${lot_return_value}=    Get Element Attribute    xpath=.//span[@dataanchor='valueAddedTaxIncluded']@textContent
  ${lot_return_value}=    tax_adapt                ${lot_return_value}
  set global variable     ${lot_return_value}




###########################################################################################################################################################

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



####################################################################################################################################################

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
  focus           xpath=(.//button[@tender-id='control.tenderId'])[${doc_counter}]
  sleep  2
  click button    xpath=(.//button[@tender-id='control.tenderId'])[${doc_counter}]
  sleep  5
  ${return_value}=    Get Text    xpath=.//a[@ng-click='loadUrl(gr)']
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
  ${return_value}=    Get Text    xpath=.//a[@ng-click='loadUrl(gr)']
  ${link}=            get value   xpath=.//a[@ng-click='loadUrl(gr)']
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
  click button    xpath=(.//button[@tender-id='control.tenderId'])[2]
  sleep  5
  ${return_value}=    Get Text    xpath=.//a[@ng-click='loadUrl(gr)']
  ${link}=            get value   xpath=.//a[@ng-click='loadUrl(gr)']
  download_file       ${link}     ${return_value}      ${OUTPUT_DIR}
  sleep  10
  [return]  ${return_value}














#####################################################################################################################################################
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

Завантажити документ
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
  #Очікуємо появи повідомлення
#  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  60
#  sleep  3
  sleep  10

Додати неціновий показник на лот
#Можливість додати неціновий показник на перший лот
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

Подати цінову пропозицію
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
    log to console  *
    log to console  ${bid_amount}
    log to console  ${bid_amount_str}
    log to console  *
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
  go to  ${ViewTenderUrl}
  sleep  10
  ${bid_doc_type}=  convert to string  commercialProposal
  set global variable  ${bid_doc_type}
  run keyword and ignore error  Отримати тип документу ставки  @{ARGUMENTS}
#  Wait Until Page Contains Element    xpath=(.//button[@ng-if='vm.allowEditBidDocuments'])[1]
#  focus                               xpath=(.//button[@ng-if='vm.allowEditBidDocuments'])[1]
#  sleep  2
#  focus                               xpath=(.//button[@ng-if='vm.allowEditBidDocuments'])[1]
#  sleep  2
#  Click element                       xpath=(.//button[@ng-if='vm.allowEditBidDocuments'])[1]
#  Sleep  5
#  focus  id=description-bid-documents
#  sleep  2
#  input text                    id=description-bid-documents              PLACEHOLDER

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
#  wait until element is visible       xpath=(.//button[@ng-if='vm.allowEditBidDocuments'])[1]    60
#  focus                               xpath=(.//button[@ng-if='vm.allowEditBidDocuments'])[1]
#  sleep  5
#  Click element    xpath=(.//button[@ng-if='vm.allowEditBidDocuments'])[1]
#  Sleep  5
#  focus  id=description-bid-documents
#  sleep  3
#  input text                    id=description-bid-documents              PLACEHOLDER_2

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
  Wait Until Page Contains Element   xpath=//ng-form[@name='questionForm'][1]//button[@ng-click='toggleView()']
  Click element     xpath=//ng-form[@name='questionForm'][1]//button[@ng-click='toggleView()']
  Sleep    5s
  input text       id=title          ${title}
  input text       id=description    ${description}
  Sleep    10
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

########################################################################################################################
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




