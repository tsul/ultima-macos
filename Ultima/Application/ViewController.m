//
//  ViewController.m
//  Ultima
//
//  Created by Taylor Sullivan on 12/4/20.
//

#import "ViewController.h"
#import "Renderer.h"
#import <simd/simd.h>
#import "World.h"

@interface Shell : MTKView
@end

@implementation Shell {
    World *_world;
}

- (void)keyDown:(NSEvent *)event {
    if (event.keyCode == 125) { // DownArrow
        [_world move:(vector_int2){1, 1}];
    } else if (event.keyCode == 123) { // LeftArrow
        [_world move:(vector_int2){-1, 1}];
    } else if (event.keyCode == 124) { // RightArrow
        [_world move:(vector_int2){1, -1}];
    } else if (event.keyCode == 126) { // UpArrow
        [_world move:(vector_int2){-1, -1}];
    }
   
}

- (void)setWorld:(World *)world {
    _world = world;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}
@end

@implementation ViewController {
    Shell *_view;
    Renderer *_renderer;
    World *_world;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _world = [[World alloc] init];
    _view = (Shell *)self.view;

    _view.device = MTLCreateSystemDefaultDevice();
//    _view.enableSetNeedsDisplay = YES;
    _view.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    
    _renderer = [[Renderer alloc] initWithMetalKitView:_view world:_world];
    
    if (!_renderer) {
        NSLog(@"Unable to initialize renderer.");
        return;
    }
    
    [_view setWorld:_world];
    [_renderer mtkView:_view drawableSizeWillChange:_view.drawableSize];
    
    _view.delegate = _renderer;
}

@end
