//
//  QMDrawingLabelLayoutData.cpp
//  QMChat
//
//  Created by Andrey Ivanov on 22.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#include "QMLabelLayoutData.h"

@interface QMLabelLayoutData () {
    
    std::vector<QMLabelLinePosition> _lineOrigins;
    std::vector<QMLabelLinkData> _links;
}

@end

@implementation QMLabelLayoutData

- (std::vector<QMLabelLinePosition> *)lineOrigins {
    
    return &_lineOrigins;
}

- (std::vector<QMLabelLinkData> *)links {
    
    return &_links;
}

- (QMLabelLinkData)linkAtPoint:(CGPoint)point {
    
    QMLabelLinkData linkData;

    for( auto &linkIt: _links){
        
        for (NSValue *rectValue in linkIt.rects) {
            
            if (CGRectContainsPoint([rectValue CGRectValue], point)) {
                
                if (linkIt.link) {
                    return linkIt;
                }
            }
        }
    }
    
    return linkData;
}

@end