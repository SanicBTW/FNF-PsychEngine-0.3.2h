package;

class Ratings
{
    public static function GenerateLetterRank(accuracy:Float)
    {
        var ranking = "?";

        if (PlayState.songMisses == 0 && PlayState.bads == 0 && 
            PlayState.shits == 0 && PlayState.goods == 0)
            ranking = "(MFC)";
        else if (PlayState.songMisses == 0 && PlayState.bads == 0 && 
            PlayState.shits == 0 && PlayState.goods >= 1)
            ranking = "(GFC)";
        else if (PlayState.songMisses == 0)
            ranking = "(FC)";
        else if (PlayState.songMisses < 10)
            ranking = "(SDCB)";
        else
            ranking = "(Clear)";

        var wifeConditions:Array<Bool> = 
        [
            accuracy >= 99.9935, // AAAAA
            accuracy >= 99.980, // AAAA:
            accuracy >= 99.970, // AAAA.
            accuracy >= 99.955, // AAAA
            accuracy >= 99.90, // AAA:
            accuracy >= 99.80, // AAA.
            accuracy >= 99.70, // AAA
            accuracy >= 99, // AA:
            accuracy >= 96.50, // AA.
            accuracy >= 93, // AA
            accuracy >= 90, // A:
            accuracy >= 85, // A.
            accuracy >= 80, // A
            accuracy >= 70, // B
            accuracy >= 60, // C
            accuracy < 60 // D
        ];

        for (i in 0...wifeConditions.length)
        {
            var b = wifeConditions[i];
            if (b)
            {
                switch (i)
                {
                    case 0:
                        ranking += " AAAAA";
                    case 1:
                        ranking += " AAAA:";
                    case 2:
                        ranking += " AAAA.";
                    case 3:
                        ranking += " AAAA";
                    case 4:
                        ranking += " AAA:";
                    case 5:
                        ranking += " AAA.";
                    case 6:
                        ranking += " AAA";
                    case 7:
                        ranking += " AA:";
                    case 8:
                        ranking += " AA.";
                    case 9:
                        ranking += " AA";
                    case 10:
                        ranking += " A:";
                    case 11:
                        ranking += " A.";
                    case 12:
                        ranking += " A";
                    case 13:
                        ranking += " B";
                    case 14:
                        ranking += " C";
                    case 15:
                        ranking += " D";
                }
                break;
            }
        }

        if (accuracy == 0 || Math.isNaN(accuracy))
            ranking = "?";

        return ranking;
    }

    public static function CalculateRating(noteDiff:Float):String
    {
        var rating = checkRating(noteDiff, Conductor.timeScale);
        return rating;
    }

    public static function checkRating(ms:Float, ts:Float)
    {
        var rating:String = "miss";

        var timingWindows:Array<Int> = [ClientPrefs.sickWindow, ClientPrefs.goodWindow, ClientPrefs.badWindow, ClientPrefs.shitWindow];

        // shit
        if (ms < timingWindows[3] * ts && ms > timingWindows[2] * ts)
            rating = "shit";
        if (ms > -timingWindows[3] * ts && ms < -timingWindows[2] * ts)
            rating = "shit";

        // bad
        if (ms < timingWindows[2] * ts && ms > timingWindows[1] * ts)
            rating = "bad";
        if (ms > -timingWindows[2] * ts && ms < -timingWindows[1] * ts)
            rating = "bad";

        // good
        if (ms < timingWindows[1] * ts && ms > timingWindows[0] * ts)
            rating = "good";
        if (ms > -timingWindows[1] * ts && ms < -timingWindows[0] * ts)
            rating = "good";

        // sick
        if (ms < timingWindows[0] * ts && ms > -timingWindows[0] * ts)
            rating = "sick";

        return rating;
    }

    public static function CalculateRanking(score:Int, misses:Int, accuracy:Float):String
    {
        var scoreString = "Score: " + score;
        var missesString = "Misses: " + misses;
        var accuracyFloorDec = Highscore.floorDecimal(accuracy * 100, 2);
        var accuracyString = "Accuracy: " + (Math.isNaN(accuracyFloorDec) ? "00.00" : '$accuracyFloorDec') + "%";
        var ratingString = GenerateLetterRank(accuracyFloorDec);

        return scoreString + " | " + missesString + " | " + accuracyString + " | " + ratingString ;
    }
}