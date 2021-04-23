//
//  String + HTMLString.swift
//  Depo
//
//  Created by Vyacheslav Bakinskiy on 11.03.21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

extension String {
    func setHTMLStringFont(_ font: UIFont, fontSizeInPixels: Int) -> String {
        let header = """
                <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no" />
                    <style>
                        body {
                            font-family: \(font.familyName);
                            font-size: \(fontSizeInPixels)px;
                        }
                    </style>
                </head>
                <body>
                """
        let content = header + self + "</body>"
        
        return content
    }
}
