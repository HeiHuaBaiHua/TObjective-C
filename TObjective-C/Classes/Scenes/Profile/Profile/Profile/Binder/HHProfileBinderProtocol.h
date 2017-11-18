#import <Foundation/Foundation.h>

#import "HHProfileViewProtocol.h"
#import "HHProfileViewModelProtocol.h"
@protocol HHProfileBinderProtocol <NSObject>

- (UIView<HHProfileViewProtocol> *)view;

@end
        