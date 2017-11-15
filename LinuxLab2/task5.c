/*
* �������� ���������, � ������� ������ � ������� ������������ 
* ���������� ����� ����������� �����.
*/

#include <stdio.h> //printf
#include <stdlib.h> //exit
#include <unistd.h> //pipe
#include <string.h> //strlen
#include <signal.h>
#include <time.h>

int parent_flag = 0;

void child_sigint_catcher(int signum)
{
    printf( "\nChild: Catched signal #%d\n", signum);
    printf("Child: My father should send me secret email!\n");
}

void parent_sigint_catcher(int signum)
{
    printf( "\nParent: Catched signal #%d\n", signum);
    printf("Parent: Sent secret email to my son!\n");
    parent_flag = 1;
}

int main()
{
	int child;
	int descr[2]; //���������� _������_ ������������ ������
	//[0] - ����� ��� ������, [1] - ����� ��� ������
	//������� ���������� �������� ����������� ����� ������
	if ( pipe(descr) == -1)
	{
        perror( "Couldn't pipe." );
		exit(1);
	}

	child = fork();
	if ( child == -1 )
	{
        perror( "Couldn't fork." );
		exit(1);
	}
	if ( child == 0 )
	{
        signal(SIGINT, child_sigint_catcher);
		
        close( descr[1] ); //������� ������ �� ������� � �����

		char msg[64];
		memset( msg, 0, 64 );
		int i = 0;
		

		//��������������� ��������� �� ������������ ������ �� 1 �������
		while( read(descr[0], &(msg[i++]), 1) != '\0' ) ;

        printf("Child: reading..\n\n");
        sleep(0.5);
        printf( "Child: read <%s>\n", msg );
	}
	else
	{
		signal(SIGINT, parent_sigint_catcher);
		
        close( descr[0] ); //������ ������ �� ������� �� ������

		
        printf( "Parent: waiting for CTRL+C signal for 3 seconds...\n" );
        sleep(3);

         if (parent_flag)
         {
             char msg[64] = "It`s my secret email for you, son. Father.";
             write( descr[1], msg, strlen(msg) ); //������� ��������� � �����

             exit(0);

         }
         else
         {
             char msg[64] = "Hello my child!";
             write( descr[1], msg, strlen(msg) ); //������� ��������� � �����
         }
		return 0;
	}
}