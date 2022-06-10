undef("get_area_wgty")
function get_area_wgty(lat, lon)
local jlat, rad, re, rr, dlon, dx, dy
begin
    jlat = dimsizes(lat)
    rad = 4.0*atan(1.0)/180.0
    re = 6371220.0
    rr = re*rad
    dlon = abs(lon(2)-lon(1))*rr
    dx = dlon*cos(lat*rad)
    dy = new(jlat, typeof(dx))
    dy(0) = abs(lat(2)-lat(1))*rr
    dy(1:jlat-2) = abs(lat(2:jlat-1)-lat(0:jlat-3))*rr*0.5
    dy(jlat-1) = abs(lat(jlat-1)-lat(jlat-2))*rr
    area = dx*dy
    copy_VarCoords(lat, area)
    return(area)
end

begin
    f1 = addfile("/cygdrive/e/ERA5/T_ERA5_1979-2021.month.mean.nc", "r")
    T = short2flt(f1->t(:, {1000:10}, :, :))
    T_clm = clmMonTLLL(T)
    T_anom = calcMonAnomTLLL(T, T_clm)
    wgty = get_area_wgty(f1->latitude, f1->longitude)
    T_clm_time_level = wgt_areaave_Wrap(T_clm, wgty, 1.0, 0)
    T_clm_min = min(T_clm_time_level)
    T_clm_max = max(T_clm_time_level)
    maxlev = 16
    mnmxint = nice_mnmxintvl(T_clm_min, T_clm_max, maxlev, False)
    T_anom_time_level = wgt_areaave_Wrap(T_anom, wgty, 1.0, 0)
    x1 = ispan(0, dimsizes(T_anom_time_level&time)-1, 1)
    T_anom_time_level&time = x1
    
    wks = gsn_open_wks("eps", "/cygdrive/c/Users/a/Desktop/cdc1")
    plot = new(2, graphic)

    res1 = True
    res1@gsnDraw = False
    res1@gsnFrame = False
    res1@vpWidthF = 0.7
    res1@vpHeightF = 0.3
    res1@cnFillOn = True  
    res1@cnLinesOn = False
    res1@cnLineLabelsOn = False
    res1@cnInfoLabelOn = False
    res1@tmYRMode = "Automatic"
    res1@tmYROn = False
    res1@tmXTOn = False
    res1@tiYAxisString = "pressure(hPa)"
    res1@tmYLMode = "Explicit"
    res1@tmYLValues = (/1000, 700, 500, 300, 200, 100, 50, 30, 10/)
    res1@tmYLLabels = (/1000, 700, 500, 300, 200, 100, 50, 30, 10/)
    res1@tmXBMode = "Explicit"
    res1@tmXBValues = ispan(0, 11, 1)
    res1@tmXBLabels = ispan(1, 12, 1)
    res1@tiXAxisString = "month"
    res1@cnFillPalette = "BlueDarkRed18"
    res1@cnLevelSelectionMode = "ManualLevels"
    res1@cnMinLevelValF = mnmxint(0)
    res1@cnMaxLevelValF = mnmxint(1)
    res1@cnLevelSpacingF = mnmxint(2)
    res1@gsnLeftString = "T_ERA5_clm"
    res1@lbOrientation = "Vertical"

    plot(0) = gsn_csm_pres_hgt(wks, transpose(T_clm_time_level), res1)

    res2 = True
    res2@gsnDraw = False
    res2@gsnFrame = False
    res2@vpWidthF = 0.7
    res2@vpHeightF = 0.3
    res2@cnFillOn = True
    res2@cnLinesOn = False
    res2@cnLineLabelsOn = False
    res2@cnInfoLabelOn = False
    res2@tmYRMode = "Automatic"
    res2@tmYROn = False
    res2@tmXTOn = False
    res2@tiYAxisString = "pressure(hPa)"
    res2@tmYLMode = "Explicit"
    res2@tmYLValues = (/1000, 700, 500, 300, 200, 100, 50, 30, 10/)
    res2@tmYLLabels = (/"1000", "700", "500", "300", "200", "100", "50", "30", "10"/)
    res2@tmXBMode = "Explicit"
    res2@tmXBValues = (/12, 72, 132, 192, 252, 312, 372, 432, 492/)
    res2@tmXBLabels = (/1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020/)
    res2@tiXAxisString = "year"
    res2@cnLevelSelectionMode = "ManualLevels"
    res2@cnMinLevelValF = -2.0
    res2@cnMaxLevelValF = 2.0
    res2@cnLevelSpacingF = 0.25
    res2@gsnLeftString = "T_ERA5_anom"
    res2@lbOrientation = "Vertical"

    plot(1) = gsn_csm_pres_hgt(wks, transpose(T_anom_time_level), res2)

    resP = True

    gsn_panel(wks, plot, (/2, 1/), resP)
end