*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=FALSE
Library             RPA.Tables
Library             RPA.HTTP
Library             Screenshot
Library             RPA.Windows
Library             RPA.Images
Library             RPA.PDF
Library             RPA.DocumentAI.Base64AI
Library             RPA.Excel.Files
Library             RPA.Archive


*** Variables ***
${output_Folder}    ${OUTPUT_DIR}
${image_folder}     ${output_Folder}${/}Image
${PDF_folder}       ${output_Folder}${/}Pdf
${Final_PDF}        ${output_Folder}${/}FinalPDF


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download the csv
    Fill the form from CSV data
    Create zip


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download the csv
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Close the annoying window
    Click Button    OK

Fill the form from CSV data
    ${table}=    Read table from CSV    orders.csv
    FOR    ${row}    IN    @{table}
        Fill the form for one order    ${row}
        Preview the button
        Take screenshot of the bot    ${row}[Order number]
        Submit Order
        Save receipt to PDF    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${row}[Order number]
        Submit another order
    END

Fill the form for one order
    [Arguments]    ${row}
    Close the annoying window
    Sleep    3sec
    Select From List By Value    xpath://*[@id="head"]    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${row}[Legs]
    Input Text    address    ${row}[Address]

Preview the button
    Click Button    xpath:/html/body/div/div/div[1]/div/div[1]/form/button[1]

Submit Order
    Click Button    xpath:/html/body/div/div/div[1]/div/div[1]/form/button[2]
    ${error}=    Run Keyword And Return Status    Page Should Contain Element    order-another
    IF    ${error}==False    Submit Order

Submit another order
    Click Button    xpath:/html/body/div/div/div[1]/div/div[1]/div/button

Save receipt to PDF
    [Arguments]    ${Order_Number}
    ${sales_results_html}=    Get Element Attribute    id:receipt    outerHTML
    Log    ${sales_results_html}
    Html To Pdf    ${sales_results_html}    ${PDF_folder}${/}Receipt_${Order_Number}.pdf

Take screenshot of the bot
    [Arguments]    ${Order_Number}
    RPA.Browser.Selenium.Screenshot
    ...    xpath:/html/body/div/div/div[1]/div/div[2]/div[2]/div
    ...    ${image_folder}${/}Image_${Order_Number}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${Order_Number}
    ${images_list}=    Create List
    ...    ${PDF_folder}${/}Receipt_${Order_Number}.pdf
    ...    ${image_folder}${/}Image_${Order_Number}.png
    Add Files To Pdf    ${images_list}    ${Final_PDF}${/}Receipt_${Order_Number}.pdf

Create zip
    Archive Folder With Zip    ${Final_PDF}    FinalZip
