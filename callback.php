<?php

require_once('LineBot.php');

// LINE:チャンネルID
$CHANNEL_ID = 1462842097;
// LINE:チャンネルシークレット
$CHANNEL_SECRET = komaki99;
// LINE:MID
$CHANNEL_MID = uba13cc7aa65749b5de894379523112f9;

// Bingアカウントキー
$ACCOUNT_KEY = Y9Ij42lqUC0uWblnfKjp2glRuWi8Du2nx9btUi/LtZQ;

$bot = new LineBot($CHANNEL_ID, $CHANNEL_SECRET, $CHANNEL_MID);
$bot->sendText('「%s」デスネ...');
$bot->sendImage($ACCOUNT_KEY);

