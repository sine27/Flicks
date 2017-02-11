//
//  MovieModel.swift
//  FlicksCollection
//
//  Created by Shayin Feng on 2/9/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

class MovieModel: NSObject {
    var original_title : String
    var overview : String
    var backdrop_path : String
    var poster_path : String
    var release_date : String
    var original_language : String
    
    var id : Int
    var popularity : Double
    var vote_average : Double
    var vote_count : Int
    var runtime : Int
    
    var adult : Bool
    
    init (original_title : String?, overview : String?, backdrop_path : String?, poster_path : String?,  release_date : String?, original_language : String?, id : Int, popularity : Double?, vote_average : Double?, vote_count : Int?, runtime : Int?, adult : Bool?) {
        self.original_title = original_title ?? "No Title"
        self.overview = overview ?? "No overview found"
        self.backdrop_path = backdrop_path ?? ""
        self.poster_path = poster_path ?? ""
        self.release_date = release_date ?? ""
        self.original_language = original_language ?? ""
        self.id = id
        self.popularity = popularity ?? 0.0
        self.vote_average = vote_average ?? 0.0
        self.vote_count = vote_count ?? 0
        self.runtime = runtime ?? 0
        self.adult = adult ?? false
    }
}
