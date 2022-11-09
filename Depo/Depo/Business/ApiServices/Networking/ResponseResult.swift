//
//  ResponseResult.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/10/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

public typealias VoidHandler = () -> Void
public typealias BoolHandler = (Bool) -> Void
public typealias IntHandler = (Int) -> Void
public typealias ValueHandler<T> = (T) -> Void
typealias ResponseString = (ResponseResult<String>) -> Void
typealias ResponseVoid = (ResponseResult<Void>) -> Void
typealias ResponseBool = (ResponseResult<Bool>) -> Void
typealias ResponseHandler<T> = (ResponseResult<T>) -> Void
typealias ResponseArrayHandler<T> = (ResponseResult<[T]>) -> Void
typealias SelfReturningHandler<T> = (T) -> Void

enum ResponseResult <T> {
    case success(T)
    case failed(Error)

    func asSwiftResult() -> Result<T, Error> {
        switch self {
        case let .success(value):
            return .success(value)
        case let .failed(error):
            return .failure(error)
        }
    }
}

enum ErrorResult<Success, Failure> where Failure: Error {
    case success(Success)
    case failure(Failure)
}
