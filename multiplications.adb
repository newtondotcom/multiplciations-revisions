--------------------------------------------------------------------------------
--  Auteur   : Robin Augereau
--  Objectif : Aider à Réviser les tables de multiplication
--------------------------------------------------------------------------------

with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;
with Ada.Calendar;          use Ada.Calendar;
with Ada.Numerics.Discrete_Random;

--Aider à Réviser les tables de multiplication
procedure Multiplications is


	generic
		Lower_Bound, Upper_Bound : Integer;	-- bounds in which random numbers are generated
		-- { Lower_Bound <= Upper_Bound }
	
	package Alea is
	
		-- Compute a random number in the range Lower_Bound..Upper_Bound.
		--
		-- Notice that Ada advocates the definition of a range type in such a case
		-- to ensure that the type reflects the real possible values.
		procedure Get_Random_Number (Resultat : out Integer);
	
	end Alea;

	
	package body Alea is
	
		subtype Intervalle is Integer range Lower_Bound..Upper_Bound;
	
		package  Generateur_P is
			new Ada.Numerics.Discrete_Random (Intervalle);
		use Generateur_P;
	
		Generateur : Generateur_P.Generator;
	
		procedure Get_Random_Number (Resultat : out Integer) is
		begin
			Resultat := Random (Generateur);
		end Get_Random_Number;
	
	begin
		Reset(Generateur);
    end Alea;
    
    	package Mon_Alea is
		new Alea (1, 10);  -- générateur de nombre dans l'intervalle [5, 15]
    use Mon_Alea;
    
    ---Définition des variables
    Table : Integer; --! contient la table de multiplication à réviser
    Score : Integer; --! comptabilise le score 
    Continuer : Boolean; --! variable qui permet de continuer ou non la révision 
    Valide : Boolean; --! définit la validité de la table entrée par l'utilisateur
    Derniere_valeur : Integer; --! mise en mémoire du chiffre de droite de la multiplication
    Moyenne: Duration; --! Somme des temps de réponse afin de calculer la moyenne
    Chiffre_max : Integer; --! Chiffre de droite associé au temps de réponse maximal
    Temps_max : Duration; --! Temps de réponse maximal associé à Chiffre_max
    Reponse : Integer; --! Réponse de l'utilisateur à chaque multiplication
    Delai : Duration; --! Temps de réponse à chaque multiplication
    Continuation:Character; --! Entrée de l'utilisateur à la fin de la série de multiplications
    Debut:Time; --! Début de l'interaction avec l'utilisateur pour récupérer sa réponse
    Fin:Time; --! Fin de l'interaction avec l'utilisateur pour récupérer sa réponse
    Chiffre_alea : Integer; --! Entier généré aléatoirement pour chaque multiplication
    
begin
    Continuer := True;
    While Continuer loop 
        
        --Demander la table à réviser
        Valide := False;
        While not Valide loop
            Put("Table à réviser: ");
            Get(Table);
            
            --Vérifier l’existence de la table Table 
            if 0<Table and Table<10 then
                Valide := True;
            else
                Put("Impossible, la table doit être comprise entre 0 et 10");
                New_Line;
            end if;
        end loop;
        
        --Afficher les 10 multiplications de la table choisie
        Chiffre_max := 0;
        Temps_max:=0.0;
        Derniere_valeur:=0;
        Score:=0;
        Moyenne:=0.0;
        for N in 1..10 loop
            
            --Déterminer un nombre aléatoire compris entre 1 et 10 
            loop
                Get_Random_Number (Chiffre_alea);
                exit when Derniere_valeur/=Chiffre_alea ;
            end loop;
            Derniere_valeur := Chiffre_alea;
            
            --Demander le résultat de la multiplication en le chronométrant
            Put("(M"&Integer'Image(N)&") "&Integer'Image(Table) & " * " & Integer'Image(Chiffre_alea) & " ? ");
            Debut:= Clock;
            Get(Reponse);
            Fin:=Clock;
            Delai := Fin - Debut;
            
            --Valider la réponse de l’utilisateur 
            if Table*Derniere_valeur = Reponse then
                Score:=Score+1;
            end if;
            
            --Comparer le temps de réponse 
            --!Calcul d’une moyenne afin de comparer le temps de réponse actuel  à la moyenne des réponses précédentes
            if Temps_max < Delai then
                Temps_max := Delai;
                Chiffre_max:=Derniere_valeur;
            else
            	Null;
            end if;
            
            Moyenne:=Moyenne + Delai;
        end loop;
        
        --Réagir au score 
        case Score is
            when 10 => Put("Aucune erreur. Excellent ! ");
            when 9 => Put("Une seule erreur. Très bien !");
            when 0 => Put("Tout est faux, volontaire ?");
            when 1..5 => Put("Seulement ");
                Put(Score);
                Put(" bonnes réponses; il faut apprendre la table de "&Integer'Image(Table)); 
                Put(" !");
            when others => Put(10-Score);
                Put(" erreurs. Il faut encore travailler la table de");
                Put(Table);
                Put(" .");
        end case;
        
        Moyenne := Moyenne/10.0;
        --Conseiller la révision d’une table 
        --!Si Chiffre_max vaut toujours 0, il n’y a eu aucune erreur de multiplication
        if Chiffre_max/=0 then
            if Temps_max > Moyenne+1.0 then
            	New_Line;
            	Put("Des hésitations sur la table de"&Integer'Image(Chiffre_max)&" :");
            	Put(Duration'Image(Temps_max));
            	Put(" secondes contre " & Duration'Image(Moyenne));
            	Put(" en moyenne. Il faut certainement la réviser");
            else
            	Null;
            end if;
        else
            Null;
        end if;
        
        --Demander si il faut continuer le jeu
        New_Line;
        Put("Voulez vous continuez le jeu ?");
        Get(Continuation);
        if Continuation='o' or Continuation ='O' then
            Continuer:=True;
        else
            Continuer:=False;
        end if;
    end loop;
end Multiplications;
