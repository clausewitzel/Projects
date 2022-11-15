--This query finds all the claims that are assigned to the PBM out reach team that are not paid and have not received a response yet.

-- Paidclaims finds claims that are still being processed since they are not recognized as paid by the system. Marking them now will allow for their removal in the future.
WITH PAIDCLAIMS AS (
                    SELECT DISTINCT
                        RR.CLAIMID
                        ,'PAID' [MARKED]
					FROM
                        rdp.opd.REJECTRESPONSE RR
					WHERE
                        RR.REJECTCODE LIKE '00' -- a pam reject code that has marked a claim to be paid
		    )
--claims selects all claims that are in billed status and have been sent in the last 2 years.
,CLAIMS AS (
            SELECT
                C.PK
                ,CC.BILLED
                ,C.LRG_INVESTIGATION_ID
                ,RE.ASSIGNEDAUDITORID
			FROM
                rdp..TBLCLAIM C
                LEFT JOIN rdp.opd.RECOVERYCLAIM RC ON RC.CLAIMID = C.PK
                LEFT JOIN rdp.opd.RECOVERYEFFORT RE ON RE RECOVERY EFFORTIF = RC.RECOVERYEFFORTID 
                OUTER APPLY (
                             SELECT 
                                 SUM(CC.NETCHECKAMOUNT) BILLED
						     FROM
                                 rdp..TBLCLAIM
                                 LEFT JOIN PAIDCLAIMS PD ON PD.CLAIMID = CC.PK
							 WHERE
                                 CC.LRG_INVESTIGATION_ID = C.LRG_INVESTIGATION_ID
                                 AND CC.LRG_CLAIM_STATUS = 2
                                 AND PD.MARKED IS NULL --This removes claims that are paid but have not entered claim status 2 yet
							 ) CC
	    WHERE
                1=1
                AND C.DATEFILLED > DATEADD(MONTH, -24, GETDATE())
                AND C.LRG_CLAIM_STATUS IN (2) --Claim status 2 is billed
                )
--Investigations creates a pivot which groups investigations by assigned team member and will remove any investigations where team members of the group out reach team have nothing assigned
,INVESTIGATIONS AS(
                   SELECT
                       PVT.LRG_INVESTIGATIONS_ID [INV]
                       ,PVT.BILLED
                       ,PVT.[401]
                       ,PVT.[433]
                       ,PVT.[520]
                       ,PVT.[568]
                       ,PVT.[572]
                       ,PVT.[591]
				   FROM
                       CLAIMS C
                       PIVOT (
                              COUNT(C.PK) FOR C.ASSIGNEDAUDITORID IN 
                              ([401],[433],[520],[568],[572],[591],[592],[985])
                              ) AS PVT
                   WHERE
                       1=1
                       AND PVT.[401] IN (0)
                       AND PVT.[433] IN (0)
                       AND PVT.[520] IN (0)
                       AND PVT.[568] IN (0)
                       AND PVT.[572] IN (0)
                       AND PVT.[591] IN (0)
                     )
--Max dates will select only the most recent date an investigation received a message
, MAXDATES AS (
               SELECT 
                   C.LRG_INVESTIGATION_ID              [INV]
                   ,MAX(CAST(RN.DATECREATED AS DATE))) [MSGDATE]
			   FROM
                   CLAIMS C
                   LEFT JOIN rdp.opd.RECOVERYCLAIM RC ON RC.CLAIMID = C.PK
                   LEFT JOIN rdp.opd.RECOVERYNOTE  RN ON RN.RECOVERYEFFORTID  = RC.RECOVERYEFFFORTID
                   LEFT JOIN rdp.opd.RECOVERYEFFORT RE ON RE.RECOVERYEFFORTID = RC.RECOVERYEFFORTID
			   GROUP BY 
                   C.LRG_INVESTIGATION_ID ,RE.RECOVERYEFFORTD
                   )
SELECT DISTINCT
    CL.CLIENTNAME [CLIENT]
    ,I.PKINVESTIGATION [INV]
    ,IR.CARRIER [OI CARRIER]
    ,IR.PBMNAME [PBM]
    ,IT.DESCRIPTION
    ,INV.BILLED
    ,IR.SELFFUNDEDPLANNAME [GROUP NAME]
FROM
    INVESTIGAITONS INV
    LEFT JOIN rdp..TBLCLAIM           C ON C.LRG_INVESTIGATION_ID = INV.INV
    LEFT JOIN MAXDATES               MD ON MD.INV = INV.INV
    LEFT JOIN rdp.opd.RECOVERYCLAIM  RC ON RC.CLAIMID = C.PK
    LEFT JOIN rdp.opd.RECOVERYEFFORT RE ON RE.RECOVERYEFFORTID = RC.RECOVERYEFFORTID
    LEFT JOIN rdp..TBLAUDITOR         A ON A.PKAUDITOR = RE.ASSIGNEDAUDITORID 
    LEFT JOIN rdp..TBLINVESTIGATION   I ON INV.INV = I.PKINVESTIGATION
    LEFT JOIN rdp..TBLCLIENT         CL ON CL.PKCLIENT = C.LRG_CLIENT_ID 
    LEFT JOIN rdp..TBLINVESTIGATION   I ON I.PKINVESTIGATION
