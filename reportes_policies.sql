CREATE POLICY reportes_select_recep_admin ON reportes FOR SELECT
    USING (current_user_role() IN ('Recepcionista', 'Administrador'));

CREATE POLICY reportes_insert_recep_admin ON reportes FOR INSERT
    WITH CHECK (current_user_role() IN ('Recepcionista', 'Administrador'));

CREATE POLICY reportes_update_admin ON reportes FOR UPDATE
    USING (current_user_role() = 'Administrador');

CREATE POLICY reportes_delete_admin ON reportes FOR DELETE
    USING (current_user_role() = 'Administrador');
