void TV_All (const char* str, int p, int kmh, int is_back) {
    TV.clear_screen();
    //TV.draw_rect(0,0,DX-1,DY-1,WHITE,-1);

    int falls = GAME.falls - (str==NULL ? 1 : 0);

    // KMH
    if (str == NULL) {
        char c = (is_back ? '*' : ' ');
        if (p == 0) {
            sprintf(STR, "--> %c %d %c    ", c, kmh, c);
        } else {
            sprintf(STR, "    %c %d %c <--", c, kmh, c);
        }
        str = STR;
    }
    TV.select_font(font8x8);
    #define K 8
    TV.print(DX/2-K*strlen(str)/2, DY/2-K/2, str);
    TV.select_font(font4x6);

    // TIME/FALLS/PACE
    int time = (GAME.time > TIMEOUT) ? 0 : (TIMEOUT-GAME.time)/1000;
    sprintf(STR, "Tempo:  %3ds", time);
    TV.print(DX-FX*strlen(STR)-1,    0, STR);
    sprintf(STR, "Quedas:  %3d", falls);
    TV.print(DX-FX*strlen(STR)-1,   FY, STR);
    if (GAME.time > 5000) {
        u32 avg   = (GAME.ps[0] + GAME.ps[1]) / 2;
        u32 pace  = avg * 10 / GAME.time;
        sprintf(STR, "Ritmo:   %3d", pace);
    } else {
        sprintf(STR, "Ritmo:  ---");
    }
    TV.print(DX-FX*strlen(STR)-1, 2*FY, STR);

    // BEFORE GET_TOTAL: pace

    // TOTAL
    TV.print(0, DY-2*FY, "TOTAL");
    sprintf(STR, "%5d", PT_Total(falls) / 100);
    TV.print(0, DY-1*FY, STR);

    // AFTER GET_TOTAL: p0/p1

    // ESQ
    TV.print(0, 0, NAMES[0]);
    {
        int n, min_, max_;
        n = PT_Bests(GAME.bests[0][1], &min_, &max_);
        sprintf(STR, "F: %2d (%3d/%3d)", n, max_, min_);
        TV.print(0, 1*FY, STR);
    }
    {
        int n, min_, max_;
        n = PT_Bests(GAME.bests[0][0], &min_, &max_);
        sprintf(STR, "B: %2d (%3d/%3d)", n, max_, min_);
        TV.print(0, 2*FY, STR);
    }
    TV.print(0, 3*FY, GAME.ps[0]/100);

    // DIR
    TV.print(DX-FX*strlen(NAMES[1])-1, DY-1*FY, NAMES[1]);
    {
        int n, min_, max_;
        n = PT_Bests(GAME.bests[1][1], &min_, &max_);
        sprintf(STR, "F: %2d (%3d/%3d)", n, max_, min_);
        TV.print(DX-FX*strlen(STR)-1, DY-2*FY, STR);
    }
    {
        int n, min_, max_;
        n = PT_Bests(GAME.bests[1][0], &min_, &max_);
        sprintf(STR, "B: %2d (%3d/%3d)", n, max_, min_);
        TV.print(DX-FX*strlen(STR)-1, DY-3*FY, STR);
    }
    sprintf(STR, "%ld", GAME.ps[1]/100);
    TV.print(DX-FX*strlen(STR)-1, DY-4*FY, STR);
}


