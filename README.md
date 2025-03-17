# N26-KYC-Data-Analysis-

## Project background

### Task 1    
As a financial institution regulated by the FCA, N26 has the obligation to verify the identity of all customers who want to open a N26 account. Each prospective customer has to go through a Know Your Customer (KYC) process by submitting a government-issued photo ID and a facial picture of themself to our partner, Veritas. Veritas then would perform 2 checks:  
• Document check: To verify that the photo ID is valid and authentic;  
• Facial Similarity check: To verify that the face in the picture is the same with that on the submitted ID.    
The customer will ‘pass’ the KYC process and get a board If the results of both Document and  Facial Similarity checks are ‘clear’. 
If the result of any check is not ‘clear’, the customer has to submit all the photos again.
The pass rate is defined as the number of customers who pass both the KYC process divided by the number of customers who attempt the process. Each customer has up to 2 attempts. The pass rate has decreased substantially for the last few weeks .Please write a report that outlines the root causes and solutions.

### Bonus Task  
You’ve asked and they have delivered. The data team, that is. You’ve noticed something odd  happening over the last few days and have requested information to investigate further. You’re  not sure what you’re looking for but you’re sure that once you get your hands on that data, you’ll  be able to figure it out in no time!   In the folder, the data team have provided six files and a message for you…  1. Communication and SQL familiarity:   a. Examine the following SQL query, and explain clearly and succinctly what it  means. Will the query work? Explain why or why not.   
WITH processed_users AS (
SELECT left(u.phone_country, 2) AS short_phone_country, u.id 
FROM users u )
SELECT t.user_id,
t.merchant_country, 
sum(t.amount / fx.rate / power(10, cd.exponent)) AS amount 
FROM transactions t 
JOIN fx_rates fx ON (fx.ccy = t.currency AND fx.base_ccy = 'EUR')
JOIN currency_details cd ON cd.currency = t.currency 
JOIN processed_users pu ON pu.id = t.user_id 
WHERE t.source = 'GAIA' 
AND pu.short_phone_country = t.merchant_country 
GROUP BY t.user_id, t.merchant_country 
ORDER BY amount DESC; 
b. Now it’s your turn! Write a query to identify users whose first transaction was  a successful card payment over $10 USD 

## Executive summary
Ensuring a seamless and compliant Know Your Customer (KYC) verification process is critical for N26 as a financial institution regulated by the FCA. Over the past few weeks, the KYC pass rate has dropped significantly, raising concerns about potential inefficiencies or underlying issues in the identity verification process. This report investigates the root causes of the declining pass rate and proposes actionable solutions to enhance the verification experience for customers.

## Insights deep-dive
1.	Declining Pass Rate
•	The overall pass rate is 85.38%, but a significant portion of customers fails at least once.
•	The pass rate drops significantly on reattempts, with only 52% passing on the second attempt and 57% on the third attempt, indicating recurring issues.
2.	Document Verification Failures
•	A high number (44,002) of document verification failures were marked as "consider”.
•	This suggests that either document quality is low (blurry, cropped, expired) or the verification criteria have become stricter.
3.	Facial Verification Failures
•	10,917 failures occurred due to "consider" results in facial similarity checks.
•	Possible reasons: poor lighting, bad angles, facial obstructions (glasses, masks), or issues with the facial recognition system.
4.	Caution & Rejection Trends
•	The most common rejection reason is related to image integrity issues, with over 24,403 cases marked as "consider" or "unidentified."
•	Image quality issues also play a role, though not as severe.
5.	Time-Based Trends
•	The pass rate fluctuates over time, with some weeks seeing a drop in approvals.
•	This may indicate seasonal patterns, changes in verification policies, or system inefficiencies.

## Recommendations 
1)	Improve Document verification process
Enhance Document Quality Checks
•	Implement real-time feedback during document upload (e.g., "Your image is blurry. Please retake.").
•	Introduce pre-submission quality assessment for document clarity and completeness.
Expand Acceptable Document Types
•	If possible, allow alternative forms of verification (secondary documents, live agent review for borderline cases).
•	Adjust system thresholds if minor document discrepancies cause excessive rejections.
Audit Veritas' Document Review Process
•	Ensure Veritas is not rejecting documents due to minor issues (e.g., slight misalignment).
•	Conduct an A/B test comparing different document verification settings.
2)	Enhance facial similarity verification
Improve User Instructions
•	Provide better guidelines for users on how to take a proper selfie (good lighting, neutral expression, no glasses or masks).
•	Consider video-based verification as an alternative to improve accuracy.
Enhance Facial Recognition Algorithm
•	Investigate if facial verification failures are due to model bias (e.g., struggles with certain skin tones, facial structures).
•	Implement liveness detection to reduce false negatives caused by poor lighting or angles.
Allow Manual Review for Edge Cases
•	Introduce a human review option for users flagged as "consider" instead of requiring a full resubmission.
3)	Optimize customer support and communication
Streamline Support for Failed Attempts
•	Offer immediate assistance (chatbot, FAQs, video guide) after a failed KYC attempt.
•	Highlight common reasons for failure in the rejection message.
Proactive Support for Users on Reattempts
•	Identify customers who failed on the first attempt and offer assistance before they try again.
•	Introduce a dedicated KYC helpline or in-app guidance to prevent repeated failures.
4)	Monitor trends and improve Reporting
Regularly Track Pass Rate Fluctuations
•	Investigate why pass rates fluctuate weekly—check if system updates, regulation changes, or data processing delays contribute.
•	Implement dashboards to monitor real-time KYC trends.
Conduct Root Cause Analysis for "Consider" Cases
•	Examine why most failures are classified as "consider" rather than outright rejections.
•	If "consider" results are overly cautious, adjust the confidence thresholds in the verification process.


[DataSet](https://www.kaggle.com/datasets/zywald/n26-kyc-challenge?select=KYC_Challenge)
