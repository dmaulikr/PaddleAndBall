//
//  ViewController.m
//  Section4-5
//
//  Created by Tamar on 3/13/16.
//  Copyright © 2016 Tamar Kandathi. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController () <UICollisionBehaviorDelegate>
@property (strong, nonatomic) UIView *paddle;
@property (strong, nonatomic) UIView *ball;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic) double ballRadius;
@property (nonatomic) CGPoint paddleCenterPoint;
@property (weak, nonatomic) IBOutlet UIButton *restartGameButton;
@end

@implementation GameViewController

double PADDLE_WIDTH = 197.0;
double PADDLE_HEIGHT = 30.0;
double BOTTOM_OFFSET = 50.0;
double BALL_RADIUS = 30.0;

-(CGPoint)paddleCenterPoint {
    return self.paddle.center;
}

-(double)ballRadius {
    if (!_ballRadius) {
        _ballRadius = BALL_RADIUS;
    }
    return _ballRadius;
}

-(UIDynamicAnimator *)animator {
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    }
    return _animator;
}

-(UIView *)paddle {
    if (!_paddle) {
        CGRect paddleRect = CGRectMake(self.view.frame.size.width / 2 - PADDLE_WIDTH / 2, self.view.frame.size.height - BOTTOM_OFFSET, PADDLE_WIDTH, PADDLE_HEIGHT);
        _paddle = [[UIView alloc] initWithFrame:paddleRect];
        _paddle.backgroundColor = [UIColor orangeColor];
        _paddle.layer.cornerRadius = 15.0;
    }
    if (_paddle.frame.origin.x < 0 ) {
        _paddle.frame = CGRectMake(0, self.view.frame.size.height - BOTTOM_OFFSET, PADDLE_WIDTH, PADDLE_HEIGHT);
    }
    if (_paddle.frame.origin.x > self.view.frame.size.width - PADDLE_WIDTH) {
        _paddle.frame = CGRectMake(self.view.frame.size.width - PADDLE_WIDTH, self.view.frame.size.height - BOTTOM_OFFSET, PADDLE_WIDTH, PADDLE_HEIGHT);
    }
    return _paddle;
}

-(UIView *)ball {
    if (!_ball) {
        _ball = [[UIView alloc] initWithFrame: CGRectMake(self.view.frame.size.width / 2 - self.ballRadius, 70, self.ballRadius * 2, self.ballRadius * 2)];
        _ball.backgroundColor = [UIColor blackColor];
        _ball.layer.cornerRadius = self.ballRadius;
    }
    return _ball;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.restartGameButton.layer.cornerRadius = 15;
    [self addBallAndPaddle];
    [self startGame];
}

-(void) addBallAndPaddle {
    [self.view addSubview: self.ball];
    [self.view addSubview:self.paddle];
}

- (IBAction)restartGame:(UIButton *)sender {
    [self resetGame];
    [self startGame];
}

-(CGFloat) randomAngle {
    int random = arc4random_uniform(4);
    switch (random) {
        case 0:
            return M_PI_2 * 0.9;
        case 1:
            return M_PI_4;
        case 2:
            return M_PI_4 * 3;
        default:
            return M_PI_2 *1.1;
    }
}

-(void) startGame {
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[self.ball]];
    gravity.angle  = [self randomAngle];
    gravity.magnitude = 1.0;
    [self.animator addBehavior:gravity];
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.ball, self.paddle]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    [self.animator addBehavior:collisionBehavior];
    collisionBehavior.collisionDelegate = self;
    
    UIDynamicItemBehavior *ballBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ball]];
    ballBehavior.elasticity = 0.9f;
    ballBehavior.friction = 0;
    ballBehavior.resistance = 0;
    [self.animator addBehavior:ballBehavior];
    
    UIDynamicItemBehavior *paddleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paddle]];
    paddleBehavior.elasticity = 0;
    paddleBehavior.friction = 0;
    paddleBehavior.allowsRotation = NO;
    paddleBehavior.density = 10000000.0;
    
    [self.animator addBehavior:paddleBehavior];
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
    if (p.y >= self.view.frame.size.height - 5.0) {
        [self resetGame];
        [self showAlert];
    }
}

-(void) showAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"You Lost! 😈" message:nil preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) resetGame {
    [self.ball removeFromSuperview];
    [self.paddle removeFromSuperview];
    self.ball = nil;
    self.paddle = nil;
    [self.animator removeAllBehaviors];
    self.animator = nil;
    [self addBallAndPaddle];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];

    CGPoint paddleCenter = CGPointMake(touchLocation.x, self.paddleCenterPoint.y);
    
    self.paddle.center = paddleCenter;
    [self.animator updateItemUsingCurrentState:self.paddle];
}

@end
