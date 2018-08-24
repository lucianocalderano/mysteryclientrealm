//
//  ResultStruct.swift
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation

struct JobResultXX {    
//    static let shared = JobResult()
    var id = 0
    var estimate_date = "" // Date [aaaa-mm-dd]
    // Mandatory. Date the user would like to do the job.
    var compiled = 0 // Boolean [0/1]
    // Mandatory. Flag if the job it’s been completed from the user. Must be enhanced automatically with 1 when the user finish to fill in the job and label the job ready to be sent.
    var compilation_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
    // Mandatory. Date and time when the user filled in the job. The date should be populate automatically with the date and the time when the user fills in the job and label it ready to be sent.
    var updated = 0 // Boolean [0/1]
    // Mandatory. Flag showing if the job it’s been updated from the user. Must be enhanced automatically with 1 when the user completed the job and label it to be sent only if the job was already completed and labeled like irregular.
    var update_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
    // Optional. Date and time the user updated the job. Must be populate automatically with date and time when the user completed the update and label the job like ready to be sent only if the job was previously competed and labeled like irregular.
    var execution_date = "" // Date [aaaa-mm-dd]
    // Mandatory. Date when the user executed the job. Must correspond with the estimated date for the execution. Id the date is different must inform the user to modify the date before the compilation.
    var execution_start_time = "" // Time [hh:mm]
    //Mandatory. Time the user started the job.
    var execution_end_time = "" // Time [hh:mm]
    // Mandatory. Time the user finished the job.
    var store_closed = 0 // Boolean [0/1]
    // Mandatory. Flag showing if it is possible to perform the job. Default value is 0. If it is not possible to perform the job flag must be set to 1. In this case you have to ask for the reason, store it in the comment field and exit compile page. The label which is shown to the user is Sei riuscito a svolgere l’incarico? Should be possible to modify by the user
    var comment = ""
    // Mandatory. Final comment from the user.
    var results = [KpiResult]() // Array
    // Mandatory. Array of Result type objects. Must contain the user’s answers.
    var positioning = PositioningResult()
    // Mandatory. Object of type Positioning. Contains the information to geolocate the beginning and the end of the job.
    
    class KpiResult {
        var kpi_id = 0
        //Mandatory. Kpi ID.
        var value = ""
        // Optional. The valuation the user gave to kpi. Depending of a kpi the value coul be text or valuation id (separated with ,). Is mandatory only if specified by kpi settings.
        var notes = ""
        // Optional. The note the user insert to give additional details to the answer (when necessary). Is mandatory only if indicated in the kpi settings.
        var attachment = ""
        // Optional. Name of the t file attached to the answer. Is present only if the kpi require to insert the attachment. Is mandatory only if indicated in the settings of the related kpi’s. the name indicated in the filed must be the same of the file insert in the .zip file.
        // Note: All the attachment present in the object Result must be insert in the file (.zip) that contains the file scheme (job.json).
    }
    
    //MARK: -
    
    class PositioningResult  {
        var start = false
        // Optional. Flag showing if the data to geolocate the user at the beginning of the job have been collected. Must the populate automatically when the user press Start. It should not be shown to the user.
        var start_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time the user press Start. It should not be shown to the user..
        var start_lat:Double = 0
        // Optional. Latitude where the user press Start. It should not be shown to the user.
        var start_lng:Double = 0
        // Optional. Longitude where the user press Start. It should not be shown to the user.
        var end = false
        // Optional. Flag showing the the data for the golocation of the user at the and of the job are been collected. Must be populate automatically when the user press Stop. It should not be shown to the user.
        var end_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time the user press end. It should not be shown to the user..
        var end_lat:Double = 0
        // Optional. Latitude where the user press end. It should not be shown to the user.
        var end_lng:Double = 0
        // Optional. Longitude where the user press end. It should not be shown to the user.
    }
}
