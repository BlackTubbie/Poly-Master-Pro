#Requires AutoHotkey v2.0

; --- SONIDO Y AVISO DE CARGA ---
SoundBeep(440, 100) ; La
SoundBeep(554, 100) ; Do#
SoundBeep(659, 150) ; Mi (Un acorde de bienvenida)

TrayTip "Poly Master Pro", "Presioná F1 para empezar a dibujar", 1

; Esto muestra un mensaje rápido en el centro de la pantalla para que sepan que arrancó
MsgBox "Poly-Master Pro está activo.`n`nPresioná F1 en cualquier momento para abrir el menú.`n(Esc para cerrar el programa)", "Iniciado", "Iconi T3"

; --- MEMORIA ---
global LastRX := "150", LastRY := "150", LastS := "1", LastType := "Círculo", LastLados := "3"

F1:: {
    global LastRX, LastRY, LastS, LastType, LastLados
    
    MyGui := Gui("+AlwaysOnTop", "Poly-Master Gold")
    MyGui.SetFont("s10", "Segoe UI")
    
    MyGui.Add("Text", "Center w180", "--- MENÚ DE DIBUJO ---")
    RadCirculo  := MyGui.Add("Radio", "vTipoCirculo " (LastType = "Círculo" ? "Checked" : ""), "Círculo / Elipse")
    RadCuadrado := MyGui.Add("Radio", "vTipoCuadrado " (LastType = "Cuadrado" ? "Checked" : ""), "Cuadrado / Rect.")
    RadPoly     := MyGui.Add("Radio", "vTipoPoly " (LastType = "Polígono" ? "Checked" : ""), "Polígono Regular")
    
    MyGui.Add("Text", "y+10", "Lados (solo Polígono):")
    EditLados := MyGui.Add("Edit", "x130 yp-3 w50", LastLados)

    MyGui.Add("Text", "x10 y+15", "Ancho (X):")
    EditX := MyGui.Add("Edit", "x100 yp-3 w80", LastRX)
    MyGui.Add("Text", "x10 y+10", "Alto (Y):")
    EditY := MyGui.Add("Edit", "x100 yp-3 w80", LastRY)
    
    MyGui.Add("Text", "x10 y+15", "Velocidad (ms):")
    EditS := MyGui.Add("Edit", "x100 yp-3 w80", LastS)

    Btn := MyGui.Add("Button", "Default x10 y+20 w180 h45", "¡DIBUJAR AHORA!")
    Btn.OnEvent("Click", Ejecutar)
    MyGui.Show("w200 h360")

    Ejecutar(*) {
        RX := Float(EditX.Value), RY := Float(EditY.Value), S := Float(EditS.Value)
        Lados := Integer(EditLados.Value), Tipo := RadCirculo.Value ? "Círculo" : (RadCuadrado.Value ? "Cuadrado" : "Polígono")
        LastRX := EditX.Value, LastRY := EditY.Value, LastS := EditS.Value, LastType := Tipo, LastLados := EditLados.Value
        MyGui.Destroy()

        Sleep(700) 
        CoordMode("Mouse", "Screen")
        MouseGetPos(&CX, &CY)
        SoundBeep(261, 150) 

        if (Tipo = "Círculo")
            DibujarPoly(CX, CY, RX, RY, 720, S)
        else if (Tipo = "Cuadrado") {
            X1 := CX - (RX/2), Y1 := CY - (RY/2), X2 := CX + (RX/2), Y2 := CY + (RY/2)
            MouseMove(X1, Y1, 0), Sleep(50), Click("Down")
            DibujaLinea(X2, Y1, S), DibujaLinea(X2, Y2, S), DibujaLinea(X1, Y2, S), DibujaLinea(X1, Y1, S)
        } else if (Tipo = "Polígono")
            DibujarPoly(CX, CY, RX, RY, Lados, S)
        
        Click("Up")
        SoundBeep(523, 200) 
    }
}

; --- FUNCIONES IGUALES ---
DibujarPoly(CX, CY, RX, RY, Lados, S) {
    Pi := 3.14159265358979
    MouseMove(CX + RX, CY, 0), Sleep(50), Click("Down")
    Loop Lados {
        Angle := A_Index * (2 * Pi / Lados)
        DibujaLinea(CX + (RX * Cos(Angle)), CY + (RY * Sin(Angle)), S)
    }
}

DibujaLinea(TargetX, TargetY, Speed) {
    MouseGetPos(&StartX, &StartY)
    Distancia := Max(Abs(TargetX - StartX), Abs(TargetY - StartY))
    Pasos := (Speed = 0) ? (Distancia / 15) : Distancia
    Loop Integer(Pasos) {
        Progreso := A_Index / Pasos
        MouseMove(StartX + (TargetX - StartX) * Progreso, StartY + (TargetY - StartY) * Progreso, 0)
        if (Speed > 0)
            Sleep(Speed)
    }
    MouseMove(TargetX, TargetY, 0)
}

Esc::ExitApp()