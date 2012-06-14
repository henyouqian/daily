@protocol DmsDelegate <NSObject>
@optional

-(void)onNetError;
-(void)onError:(const char*)error;
-(void)onLoginWithError:(int)error userid:(int)userid gcid:(const char*)gcid datetime:(const char*)datetime topRankId:(int)topRankId unread:(int)unread;
-(void)onHeartBeatWithError:(int)error datetime:(const char*)datetime topRankId:(int) topRankId:(int)unread;
-(void)onGetTodayGamesWithError:(int)error games:(const std::vector<DmsGame>&)games;
-(void)onStartGameWithError:(int)error gameid:(int)gameid;
-(void)onSubmitScoreWithError:(int)error gameid:(int)gameid score:(int)score;
-(void)onGetUnreadWithError:(int)error unread:(int)unread topid:(int)topid;
-(void)onGetTimelineWithError:(int)error ranks:(const std::vector<DmsRank>&)ranks;

@end
