CREATE POLICY habitaciones_select_all ON habitaciones FOR SELECT
    USING (true);

CREATE POLICY habitaciones_insert_admin ON habitaciones FOR INSERT
    WITH CHECK (current_user_role() = 'Administrador');

CREATE POLICY habitaciones_update_admin ON habitaciones FOR UPDATE
    USING (current_user_role() = 'Administrador');

CREATE POLICY habitaciones_update_estado_recep ON habitaciones FOR UPDATE
    USING (current_user_role() = 'Recepcionista')

CREATE POLICY habitaciones_delete_admin ON habitaciones FOR DELETE
    USING (current_user_role() = 'Administrador');
