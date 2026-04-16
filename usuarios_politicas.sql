-- Obtener el rol de los usuarios
CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS rol
LANGUAGE plpgsql SECURITY DEFINER
STABLE
AS $$
DECLARE
	user_role rol;
BEGIN
  SELECT rol_usuario INTO user_role
  FROM public.usuarios
  WHERE auth_id = auth.uid()
  LIMIT 1;
  RETURN user_role;
END;
$$;

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

-- Políticas
CREATE POLICY "Usuarios actualizan su perfil solo con email confirmado"
ON public.usuarios
FOR UPDATE USING (
  auth.uid() = auth_id AND email_confirmed()
);

CREATE POLICY "Usuarios pueden insertarse una vez ya se hayan autenticado"
ON public.usuarios
for insert to authenticated
WITH CHECK (true);

-- Política para SELECT: controla qué pueden VER
CREATE POLICY "Control de visibilidad de usuarios" 
ON public.usuarios 
FOR SELECT USING (
	(auth.uid() = auth_id)
	OR
	(current_user_role() = 'Administrador')
	OR
	(current_user_role() = 'Recepcionista' AND rol_usuario != 'Administrador')
);
