//
//  ResponseResult.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/10/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

public typealias VoidHandler = () -> Void
typealias ResponseVoid = (ResponseResult<Void>) -> Void
typealias ResponseHandler<T> = (ResponseResult<T>) -> Void
typealias ResponseArrayHandler<T> = (ResponseResult<[T]>) -> Void

enum ResponseResult <T> {
    case success(T)
    case failed(Error)
}
