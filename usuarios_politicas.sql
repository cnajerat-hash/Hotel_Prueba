-- Función para verificar la activación por correo
CREATE OR REPLACE FUNCTION public.email_confirmed()
RETURNS BOOLEAN AS $$
DECLARE
confirmed BOOLEAN;
BEGIN
	SELECT (email_confirmed_at IS NOT NULL) INTO confirmed FROM auth.users WHERE id = auth.uid();
	RETURN COALESCE(confirmed, FALSE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.email_confirmed() TO authenticated, anon;

CREATE POLICY "Usuarios ven su propio perfil solo con email confirmado"
ON public.usuarios
FOR SELECT USING (
  auth.uid() = auth_id AND email_confirmed()
);

CREATE POLICY "Usuarios actualizan su perfil solo con email confirmado"
ON public.usuarios
FOR UPDATE USING (
  auth.uid() = auth_id AND email_confirmed()
);

-- Si el usuario ya se insertó pero no validó su correo, de todos modos se insertará
CREATE POLICY "Usuarios insertan su propio registro"
ON public.usuarios
FOR INSERT WITH CHECK (auth.uid() = auth_id);

CREATE POLICY "Administradores ven todos los usuarios"
ON public.usuarios
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.usuarios
    WHERE auth_id = auth.uid() AND rol_usuario = 'Administrador'
  )
);
