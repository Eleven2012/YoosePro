//
//  RingType.h
//  VoIP_iPhone
//
//  Created by First Mac on 7/6/11.
//  Copyright 2011 Cienet. All rights reserved.
//

    //typedef enum EN_MTC_RING_TYPE
    //{
    //    EN_MTC_RING_TONE_0,              /**< @brief tone 0 */
    //    EN_MTC_RING_TONE_1,              /**< @brief tone 1 */
    //    EN_MTC_RING_TONE_2,              /**< @brief tone 2 */
    //    EN_MTC_RING_TONE_3,              /**< @brief tone 3 */
    //    EN_MTC_RING_TONE_4,              /**< @brief tone 4 */
    //    EN_MTC_RING_TONE_5,              /**< @brief tone 5 */
    //    EN_MTC_RING_TONE_6,              /**< @brief tone 6 */
    //    EN_MTC_RING_TONE_7,              /**< @brief tone 7 */
    //    EN_MTC_RING_TONE_8,              /**< @brief tone 8 */
    //    EN_MTC_RING_TONE_9,              /**< @brief tone 9 */
    //    EN_MTC_RING_TONE_STAR,           /**< @brief tone * */
    //    EN_MTC_RING_TONE_POUND,          /**< @brief tone # */
    //    
    //    EN_MTC_RING_RING,                /**< @brief ring */
    //    EN_MTC_RING_RING_BACK,           /**< @brief ring back */
    //    EN_MTC_RING_CALL_FAILED,         /**< @brief call failed */
    //    EN_MTC_RING_BUSY,                /**< @brief busy */
    //    EN_MTC_RING_CALL_WAIT,           /**< @brief call waiting */
    //    EN_MTC_RING_FORWARD,             /**< @brief forwarding */
    //    EN_MTC_RING_TERM,                /**< @brief call terminated */
    //    EN_MTC_RING_HELD,                /**< @brief call held */
    //    
    //    EN_MTC_RING_MSG_RECV,            /**< @brief message received */
    //    EN_MTC_RING_SIZE                 /**< @brief ring size */
    //} EN_MTC_RING_TYPE;

//#define NOT_PLAY_SOUND

enum ERingType {
    E_RING_TONE_0,
    E_RING_TONE_1,
    E_RING_TONE_2,
    E_RING_TONE_3,
    E_RING_TONE_4,
    E_RING_TONE_5,
    E_RING_TONE_6,
    E_RING_TONE_7,
    E_RING_TONE_8,
    E_RING_TONE_9,
    E_RING_TONE_STAR,
    E_RING_TONE_POUND,
    
    E_RING_RING,
    E_RING_RING_BACK,
    E_RING_CALL_FAILED,
    E_RING_BUSY,
    E_RING_CALL_WAIT,
    E_RING_FORWARD,
    E_RING_TERM,
    E_RING_HELD,
    
    E_RING_MSG_RECV,
    E_RING_SIZE
};